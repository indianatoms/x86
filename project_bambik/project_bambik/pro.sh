rm project.exe project.o
nasm -f elf32 project.asm -o project.o
gcc -g -m32 project.cpp project.o -o project.exe
./project.exe
