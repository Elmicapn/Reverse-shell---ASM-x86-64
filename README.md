# Reverse-shell---ASM-x86-64

# Lancement
nasm -felf64 socket.asm -o socket.o
ld socket.o -o socket

./socket