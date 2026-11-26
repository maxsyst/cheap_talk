; Linux x86_64 NASM assembly - with structured debug logging to stderr
; Assemble: nasm -f elf64 show_code.asm -o show_code.o
; Link:     gcc show_code.o -o show_code_asm  (gcc provides _start -> main entry)
; Or:       ld show_code.o -o show_code_asm   (needs _start entry, see _main below)

section .data
    ; Main output message (stdout)
    message     db 'Talk is cheap. Show me the code.', 0xA
    msglen      equ $ - message

    ; Debug log lines (stderr)
    dbg_start   db 'INFO  | main      | === Process started ===', 0xA
    dbg_start_l equ $ - dbg_start
    dbg_enter   db 'DEBUG | show_code | Entering show_code()', 0xA
    dbg_enter_l equ $ - dbg_enter
    dbg_print   db 'DEBUG | show_code | Preparing to print to stdout', 0xA
    dbg_print_l equ $ - dbg_print
    dbg_done    db 'DEBUG | show_code | write completed', 0xA
    dbg_done_l  equ $ - dbg_done
    dbg_exit    db 'DEBUG | show_code | Exiting show_code()', 0xA
    dbg_exit_l  equ $ - dbg_exit
    dbg_end     db 'INFO  | main      | === Process finished ===', 0xA
    dbg_end_l   equ $ - dbg_end

section .text
    global main

; Linux x86_64 syscall numbers
SYS_write    equ 1
SYS_exit     equ 60

; write_stderr(rsi=msg, rdx=len) -- writes to fd=2 (stderr)
write_stderr:
    mov     rax, SYS_write
    mov     rdi, 2              ; fd: stderr
    syscall
    ret

; write_stdout(rsi=msg, rdx=len) -- writes to fd=1 (stdout)
write_stdout:
    mov     rax, SYS_write
    mov     rdi, 1              ; fd: stdout
    syscall
    ret

show_code:
    ; DEBUG: Entering show_code()
    lea     rsi, [rel dbg_enter]
    mov     rdx, dbg_enter_l
    call    write_stderr

    ; DEBUG: Preparing to print
    lea     rsi, [rel dbg_print]
    mov     rdx, dbg_print_l
    call    write_stderr

    ; Write message to stdout
    lea     rsi, [rel message]
    mov     rdx, msglen
    call    write_stdout

    ; DEBUG: write completed
    lea     rsi, [rel dbg_done]
    mov     rdx, dbg_done_l
    call    write_stderr

    ; DEBUG: Exiting show_code()
    lea     rsi, [rel dbg_exit]
    mov     rdx, dbg_exit_l
    call    write_stderr

    ret

main:
    ; INFO: Process started
    lea     rsi, [rel dbg_start]
    mov     rdx, dbg_start_l
    call    write_stderr

    ; Call show_code
    call    show_code

    ; INFO: Process finished
    lea     rsi, [rel dbg_end]
    mov     rdx, dbg_end_l
    call    write_stderr

    ; Exit
    mov     rax, SYS_exit
    mov     rdi, 0
    syscall
