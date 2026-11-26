; Debug version of show_code_win.asm - logs trace to stderr, output to stdout
; Assemble: nasm -f win64 -g show_code_debug_win.asm -o show_code_debug_win.obj
; Link:     gcc -g show_code_debug_win.obj -o show_code_debug_win.exe

extern GetStdHandle
extern WriteFile
extern ExitProcess

STD_OUTPUT_HANDLE equ -11
STD_ERROR_HANDLE  equ -12

section .data
    ; Main output message
    message     db 'Talk is cheap. Show me the code.', 0xA
    msglen      equ $ - message

    ; Debug log lines (stderr)
    dbg_start   db 'INFO  | main      | === Process started ===', 0xA
    dbg_start_l equ $ - dbg_start
    dbg_enter   db 'DEBUG | show_code | Entering show_code()', 0xA
    dbg_enter_l equ $ - dbg_enter
    dbg_print   db 'DEBUG | show_code | Preparing to print to stdout', 0xA
    dbg_print_l equ $ - dbg_print
    dbg_done    db 'DEBUG | show_code | WriteFile completed', 0xA
    dbg_done_l  equ $ - dbg_done
    dbg_exit    db 'DEBUG | show_code | Exiting show_code()', 0xA
    dbg_exit_l  equ $ - dbg_exit
    dbg_end     db 'INFO  | main      | === Process finished ===', 0xA
    dbg_end_l   equ $ - dbg_end

section .bss
    written     resd 1
    stderr_fd   resq 1
    stdout_fd   resq 1

section .text
    global main

; write_stderr(rdx=msg, r8d=len) -- uses stderr_fd
; Caller provides shadow space (sub rsp, 40 before call)
write_stderr:
    sub     rsp, 40                  ; shadow space (32) + alignment (8)
    mov     rcx, [rel stderr_fd]
    lea     r9,  [rel written]
    mov     qword [rsp+32], 0        ; lpOverlapped = NULL
    call    WriteFile
    add     rsp, 40
    ret

show_code:
    sub     rsp, 40                  ; shadow space (32) + align (8)

    ; DEBUG: Entering show_code()
    lea     rdx, [rel dbg_enter]
    mov     r8d, dbg_enter_l
    call    write_stderr

    ; DEBUG: Preparing to print
    lea     rdx, [rel dbg_print]
    mov     r8d, dbg_print_l
    call    write_stderr

    ; WriteFile(stdout, message, msglen, &written, NULL)
    mov     rcx, [rel stdout_fd]
    lea     rdx, [rel message]
    mov     r8d, msglen
    lea     r9,  [rel written]
    mov     qword [rsp+32], 0
    call    WriteFile

    ; DEBUG: WriteFile completed
    lea     rdx, [rel dbg_done]
    mov     r8d, dbg_done_l
    call    write_stderr

    ; DEBUG: Exiting show_code()
    lea     rdx, [rel dbg_exit]
    mov     r8d, dbg_exit_l
    call    write_stderr

    add     rsp, 40
    ret

main:
    sub     rsp, 40                  ; shadow space + alignment

    ; Get stderr handle
    mov     ecx, STD_ERROR_HANDLE
    call    GetStdHandle
    mov     [rel stderr_fd], rax

    ; Get stdout handle
    mov     ecx, STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     [rel stdout_fd], rax

    ; INFO: Process started
    lea     rdx, [rel dbg_start]
    mov     r8d, dbg_start_l
    call    write_stderr

    ; Call show_code
    call    show_code

    ; INFO: Process finished
    lea     rdx, [rel dbg_end]
    mov     r8d, dbg_end_l
    call    write_stderr

    add     rsp, 40
    xor     eax, eax
    ret
