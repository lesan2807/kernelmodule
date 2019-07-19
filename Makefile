obj-m += vFunctionMod.o
obj-m += deviceDriverMod.o
vFunctionMod-objs += vFunction.o vFunctionMod.o  
deviceDriverMod-objs += vFunctionDev.o errors.o deviceDriver.o 


all:
	nasm -f elf64 vFunctionDev.asm
	nasm -f elf64 vFunction.asm
	nasm -f elf64 errors.asm
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules
	
clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
test:
	sudo dmesg -C
	sudo insmod deviceDriver.ko
	sudo rmmod deviceDriver.ko
	dmesg
