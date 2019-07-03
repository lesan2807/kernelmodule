#include "usertokernel.h"

#include <iostream>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

// TODO: get all error messages and send them to GUI

usertokernel::usertokernel()
{

}

int usertokernel::callKernel(const char stringToSend[BUFFER_LENGTH])
{
    int fileDevice;
    ssize_t ret;

    printf("Starting device...\n");
    fileDevice = open(DEV_FILE, O_RDWR);
    if(fileDevice < 0)
    {
        perror("Failed to open device");
        return errno;
    }

    printf("Writting message to device [%s]\n", stringToSend);
    ret = write(fileDevice, stringToSend, strlen(stringToSend));
    if( ret < 0 )
    {
       perror("Failed to write message to the device");
       return errno;
    }
    printf("Type ENTER to read back from device\n");
    getchar();

    printf("Reading form device\n");
    ret = read(fileDevice, recieve, BUFFER_LENGTH);
    if(ret < 0)
    {
        perror("Failed to read message from the device");
        return errno;
    }
    printf("The recieved message is: [%s]\n", recieve);
    printf("End of program \n");

    return 0;
}
