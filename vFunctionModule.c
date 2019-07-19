#include <linux/init.h>           // Macros used to mark up functions e.g. __init __exit
#include <linux/module.h>         // Core header for loading LKMs into the kernel
#include <linux/device.h>         // Header to support the kernel Driver Model
#include <linux/kernel.h>         // Contains types, macros, functions for the kernel
#include <linux/fs.h>             // Header for the Linux file system support
#include <linux/uaccess.h>        // Required for the copy to user function

#include <linux/module.h>  /* Needed by all modules */
#include <linux/kernel.h>  /* Needed for KERN_INFO */
#include <linux/init.h>    /* Needed for the macros */

#define  DEVICE_NAME "vFunction"    ///< The device will appear at /dev/vFunction using this value
#define  CLASS_NAME  "points"        ///< The device class -- this is a character device driver


MODULE_LICENSE("GPL");            ///< The license type -- this affects available functionality
MODULE_VERSION("0.3");            

 
static struct class*  vFunctionClass  = NULL; ///< The device-driver class struct pointer
static struct device* vFunctionDevice = NULL; ///< The device-driver device struct pointer
extern void calcularPuntos(char*, double*, char*);
int calcular(char* info, double* points, char* increment){
   
   printk(KERN_INFO "Calculating points...\n");
   calcularPuntos(info, points, increment); 
   printk (KERN_INFO "Points are calculate\n");
   return 0;
}
EXPORT_SYMBOL(calcular);
static int __init vFunction_init(void){
   printk(KERN_INFO "vFunction: Initializing the vFunction LKM\n");
   return 0;
}
 
static void __exit vFunction_exit(void){

   printk(KERN_INFO "vFunction: Closing the vFunctionDriver\n");
}
module_init(vFunction_init);
module_exit(vFunction_exit);