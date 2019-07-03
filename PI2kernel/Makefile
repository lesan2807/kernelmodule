obj-m += kernelModule.o
obj-m += device.o 

mymodule-objs += mymodule-base.o calculo.o

allofit: modules 
	sudo insmod kernelModule.ko 
	sudo insmod device.ko

modules: calculo.o # codigo objeto del ensamblador
	@$(MAKE) -C $(KROOT) M=$(PWD) modules 

modules-install:
	@$(MAKE) -C $(KROOT) M=$(PWD) modules_install

calculo.o: calcularPuntos.asm 
	nasm -f elf64 calcularPuntos.asm

kernel_clean:
	@$(MAKE) -C $(KROOT) M=$(PWD) clean	

clean: kernel_clean
	rm -rf  Module.symvers modules.order
