# Reverse-shell---ASM-x86-64
POINEN Micael <br>
MIRAOUI Ilyes <br>
3SI2

# Lancement
nasm -f elf64 socket.asm -o socket.o <br>
ld socket.o -o socket<br>
./socket