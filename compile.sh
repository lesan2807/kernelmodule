nasm -f elf64 vFunctionDev.asm
nasm -f elf64 vFunction.asm
nasm -f elf64 errors.asm
gcc -g -no-pie vFunctionDev.o vFunction.o errors.o avxMain.c -o avx

