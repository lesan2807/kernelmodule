#include <linux/init.h>           // Macros used to mark up functions e.g. __init __exit
#include <linux/module.h>         // Core header for loading LKMs into the kernel
#include <linux/device.h>         // Header to support the kernel Driver Model
#include <linux/kernel.h>         // Contains types, macros, functions for the kernel
#include <linux/fs.h>             // Header for the Linux file system support
#include <linux/uaccess.h>          // Required for the copy to user function
#include <linux/mutex.h>

#include <linux/module.h> /* Needed by all modules */
#include <linux/kernel.h> /* Needed for KERN_INFO */
#include <linux/init.h>   /* Needed for the macros */

MODULE_LICENSE("GPL");

#define  DEVICE_NAME "vFunctionDev"    ///< The device will appear at /dev/vFunctionDev using this value
#define  CLASS_NAME  "device"        ///< The device class -- this is a character device driver
MODULE_LICENSE("GPL");            ///< The license type -- this affects available functionality
MODULE_VERSION("1.0");            ///< A version number to inform users

// Assembly functions 
extern void calcularPuntos(char*, double*, char*); 
extern int verificarErrores(char*, char*, char*); 
extern int parser(char*, char*, char*, char*); 
// VFunction function 
extern void calcular(char*, double*, char*);

static int    majorNumber;                  ///< Stores the device number -- determined automatically
static int    numberOpens = 0;              ///< Counts the number of times the device is opened
static struct class*  vFunctionDevClass  = NULL; ///< The device-driver class struct pointer
static struct device* vFunctionDevDevice = NULL; ///< The device-driver device struct pointer
static char*  messageToSend = NULL;
static double* points; 
static size_t sizeMessageToSend; 

static DEFINE_MUTEX(vFunctionDev_mutex);

// The prototype functions for the character driver -- must come before the struct definition
static int     dev_open(struct inode *, struct file *);
static int     dev_release(struct inode *, struct file *);
static ssize_t dev_read(struct file *, char *, size_t, loff_t *);
static ssize_t dev_write(struct file *, const char *, size_t, loff_t *);

/** @brief Devices are represented as file structure in the kernel. The file_operations structure from
*  /linux/fs.h lists the callback functions that you wish to associated with your file operations
*  using a C99 syntax structure. char devices usually implement open, read, write and release calls
*/
static struct file_operations fops =
{
  .open = dev_open,
  .read = dev_read,
  .write = dev_write,
  .release = dev_release,
};

/** @brief The LKM initialization function
*  The static keyword restricts the visibility of the function to within this C file. The __init
*  macro means that for a built-in driver (not a LKM) the function is only used at initialization
*  time and that it can be discarded and its memory freed up after that point.
*  @return returns 0 if successful
*/
static int __init vFunctionDev_init(void){
  printk(KERN_INFO "vFunctionDev: Initializing the vFunctionDev LKM\n");

// Try to dynamically allocate a major number for the device -- more difficult but worth it
  majorNumber = register_chrdev(0, DEVICE_NAME, &fops);
  if (majorNumber<0){
    printk(KERN_ALERT "vFunctionDev failed to register a major number\n");
    return majorNumber;
  }
  printk(KERN_INFO "vFunctionDev: registered correctly with major number %d\n", majorNumber);

// Register the device class
  vFunctionDevClass = class_create(THIS_MODULE, CLASS_NAME);
  if (IS_ERR(vFunctionDevClass)){                // Check for error and clean up if there is
    unregister_chrdev(majorNumber, DEVICE_NAME);
    printk(KERN_ALERT "Failed to register device class\n");
    return PTR_ERR(vFunctionDevClass);          // Correct way to return an error on a pointer
  }
  printk(KERN_INFO "vFunctionDev: device class registered correctly\n");

  // Register the device driver
  vFunctionDevDevice = device_create(vFunctionDevClass, NULL, MKDEV(majorNumber, 0), NULL, DEVICE_NAME);
  if (IS_ERR(vFunctionDevDevice)){               // Clean up if there is an error
    class_destroy(vFunctionDevClass);           // Repeated code but the alternative is goto statements
    unregister_chrdev(majorNumber, DEVICE_NAME);
    printk(KERN_ALERT "Failed to create the device\n");
    return PTR_ERR(vFunctionDevDevice);
  }
  printk(KERN_INFO "vFunctionDev: device class created correctly\n"); // Made it! device was initialized
  mutex_init (&vFunctionDev_mutex);
  return 0;
}

/** @brief The LKM cleanup function
*  Similar to the initialization function, it is static. The __exit macro notifies that if this
*  code is used for a built-in driver (not a LKM) that this function is not required.
*/
static void __exit vFunctionDev_exit(void){
  mutex_destroy (&vFunctionDev_mutex);
  device_destroy(vFunctionDevClass, MKDEV(majorNumber, 0));     // remove the device
  class_unregister(vFunctionDevClass);                          // unregister the device class
  class_destroy(vFunctionDevClass);                             // remove the device class
  unregister_chrdev(majorNumber, DEVICE_NAME);             // unregister the major number
  if(messageToSend != NULL){
    vfree(messageToSend);
    messageToSend = NULL;
  }
  printk(KERN_INFO "vFunctionDev: Goodbye from the LKM!\n");
}

/** @brief The device open function that is called each time the device is opened
*  This will only increment the numberOpens counter in this case.
*  @param inodep A pointer to an inode object (defined in linux/fs.h)
*  @param filep A pointer to a file object (defined in linux/fs.h)
*/
static int dev_open(struct inode *inodep, struct file *filep){
  if (!mutex_trylock(&vFunctionDev_mutex)) {
    printk(KERN_ALERT "vFunctionDev: Device in use by another process\n");\
    return -EBUSY;
  }
  numberOpens++;
  printk(KERN_INFO "vFunctionDev: Device has been opened %d time(s)\n", numberOpens);
  return 0;
}

/** @brief This function is called whenever device is being read from user space i.e. data is
*  being sent from the device to the user. In this case is uses the copy_to_user() function to
*  send the buffer string to the user and captures any errors.
*  @param filep A pointer to a file object (defined in linux/fs.h)
*  @param buffer The pointer to the buffer to which this function writes the data
*  @param len The length of the b
*  @param offset The offset if required
*/
static ssize_t dev_read(struct file *filep, char *buffer, size_t len, loff_t *offset){
  char* info;
  char* range;
  char* function;
  char* incr;
  char* pch; 
  int count; 
  int error_count;
  int b; 

  points = (double*)vzalloc(len); 

  info = (char*)vzalloc(4096); 
  range = (char*)vzalloc(2048); 
  function = (char*)vzalloc(2048); 
  incr = (char*)vzalloc(1024); 

  count = 0; 


  
  while( (pch = strsep(&messageToSend, ",")) != NULL )
  {
    if (count == 0)
      range = pch; 
    else if (count == 1)
      function = pch; 
    else if( count == 2)
      incr = pch; 
    ++count;
  } 

  error_count = verificarErrores(range, function, incr); 
  b = -1; 
  if(error_count == 0)
    b = parser(range, function, incr, info); 
  else 
    return error_count; 
  if(b == 0)
    calcular(info, points, incr); 

  error_count = copy_to_user(buffer, (char*)points, len); 

  if (error_count==0)
  {            // if true then have success
    printk(KERN_INFO "vFunctionDev: Sent %zu characters to the user\n", len);
    return 0;  // clear the position to the start and return 0
  }
  else 
  {
    printk(KERN_INFO "vFunctionDev: Failed to send %d characters to the user\n", error_count);
    return -EFAULT;              // Failed -- return a bad address message (i.e. -14)
  }
  if(messageToSend != NULL){
    vfree(messageToSend);
    messageToSend = NULL;
  }

}

/** @brief This function is called whenever the device is being written to from user space i.e.
*  data is sent to the device from the user. 
*  @param filep A pointer to a file object
*  @param buffer The buffer to that contains the string to write to the device
*  @param len The length of the array of data that is being passed in the const char buffer
*  @param offset The offset if required
*/
static ssize_t dev_write(struct file *filep, const char *buffer, size_t len, loff_t *offset){
  int i;
  printk(KERN_INFO "vFunctionDev: Received %s, %zu characters from the user\n", buffer,len);

  messageToSend = (char*) vmalloc (len);
  if (messageToSend == NULL){ 
    printk(KERN_INFO "Error with vmalloc\n");
    return -1;
  }
  sizeMessageToSend = len;
  i = 0;
  for(;i<len;i++)
  {
    messageToSend[i] = buffer[i];
  }

  return 0;
}

/** @brief The device release function that is called whenever the device is closed/released by
*  the userspace program
*  @param inodep A pointer to an inode object (defined in linux/fs.h)
*  @param filep A pointer to a file object (defined in linux/fs.h)
*/
static int dev_release(struct inode *inodep, struct file *filep){
  mutex_unlock (&vFunctionDev_mutex);
  printk(KERN_INFO "vFunctionDev: Device successfully closed\n");
  return 0;
}

/** @brief A module must use the module_init() module_exit() macros from linux/init.h, which
*  identify the initialization function at insertion time and the cleanup function (as
*  listed above)
*/
module_init(vFunctionDev_init);
module_exit(vFunctionDev_exit);