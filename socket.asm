section .data
    ; sockaddr_in struct (16 bytes)
    ; sin_family (2 bytes) = AF_INET = 2
    ; sin_port (2 bytes) = port en big endian (ici 4444)
    ; sin_addr (4 bytes) = IP en binaire (ici 127.0.0.1)
    ; sin_zero (8 bytes) = zeros

    sockaddr_in:
        dw 2                      ; sin_family = AF_INET (2)
        dw 0x5c11                 ; sin_port = 4444 en big endian (0x115c)
        dd 0x0100007f             ; sin_addr = 127.0.0.1 (0x7f000001 en réseau, inversé en little endian)
        dq 0                      ; sin_zero = 8 bytes zero

section .text
    global _start

_start:
    mov rax, 41        ; sys_socket
    mov rdi, 2         ; AF_INET
    mov rsi, 1         ; SOCK_STREAM
    mov rdx, 0         ; protocol 0
    syscall

    ; résultat dans rax (socket fd)
    cmp rax, 0
    jl .error

    ; Juste pour test, on quitte proprement
    mov rax, 60        ; sys_exit
    xor rdi, rdi       ; status 0
    syscall

.error:
    ; erreur, exit avec code 1
    mov rax, 60
    mov rdi, 1
    syscall
