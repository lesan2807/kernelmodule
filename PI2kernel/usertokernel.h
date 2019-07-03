#pragma once
#ifndef USERTOKERNEL_H
#define USERTOKERNEL_H

#define BUFFER_LENGTH 1024
#define DEV_FILE "/dev/ebbchar"
static char recieve[BUFFER_LENGTH];

class usertokernel
{
public:
    usertokernel();
    int callKernel(const char stringToSend[BUFFER_LENGTH]);
};

#endif
