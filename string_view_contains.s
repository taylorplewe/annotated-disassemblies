find:
        ; rcx = pointer to string_view instance
        ; rdx = pointer to first character of `needle` C string

        sub     rsp, 88                 ; set up stack frame
        mov     QWORD PTR [rsp+48], rdi ; preserve rdi
        mov     rdi, rcx                ; rdi = pointer to string_view instance
        mov     rcx, rdx                ; rcx = pointer to first character of `needle` C string
        mov     QWORD PTR [rsp+32], rbx ; preserve rbx
        mov     QWORD PTR [rsp+40], rsi ; preserve rsi
        mov     rsi, rdx                ; rsi = pointer to first character of `needle` C string
        call    "strlen"                ; rcx = needle (char*) = first param
        ; rax = length of `needle` string
        mov     rbx, rax                ; rbx = length of `needle`
        mov     eax, 1
        test    rbx, rbx
        je      .CleanUpAndExit         ; return true if length of `needle` is 0
        mov     r8, QWORD PTR [rdi]     ; r8 = length of string_view's string
        test    r8, r8                  
        je      .ReturnFalse            ; return false if length of string_view's string is 0
        cmp     r8, rbx
        jb      .ReturnFalse            ; return false if length of string_view's string is < `needle`
        mov     QWORD PTR [rsp+72], r13 ; preserve r13
        mov     r13, QWORD PTR [rdi+8]  ; r13 = pointer to first char of string_view's string
        mov     edi, 1
        mov     QWORD PTR [rsp+64], r12 ; preserve r12
        sub     rdi, rbx                ; rdi = 1 - needle.len
        mov     QWORD PTR [rsp+56], rbp ; preserve rbp
        lea     r12, [r13+0+r8]         ; r12 = pointer to byte after string_view's string
        mov     rcx, r13                ; rcx = pointer to first char of string_view's string
        mov     QWORD PTR [rsp+80], r14 ; preserve r14
        movsx   ebp, BYTE PTR [rsi]     ; bpl = first character of `needle` C string

; .L6
.MainCheckLoop:
        add     r8, rdi         ; 
        je      .CleanUpExtraRegsAndReturnFalse
        mov     edx, ebp
        ; memchr(sv.str, needle[0], remaining_len)
        call    "memchr"
        mov     r14, rax        ; r14 = pointer to first character of string_view's string or 0 if character was not found in the string
        test    rax, rax
        je      .CleanUpExtraRegsAndReturnFalse ; return false if character wasn't found (`needle` does not occur in string)
        mov     r8, rbx
        mov     rdx, rsi
        mov     rcx, rax
        call    "memcmp"
        test    eax, eax
        je      .L23
        lea     rcx, [r14+1]
        mov     r8, r12
        sub     r8, rcx
        cmp     r8, rbx
        jnb     .MainCheckLoop

; .L21
.CleanUpExtraRegsAndReturnFalse:
        mov     rbp, QWORD PTR [rsp+56]
        mov     r12, QWORD PTR [rsp+64]
        mov     r13, QWORD PTR [rsp+72]
        mov     r14, QWORD PTR [rsp+80]
        ; fall thru

; .L3
.ReturnFalse:
        xor     eax, eax
        ; fall thru

; .L1
; pop preserved register values, restore stack frame and exit
.CleanUpAndExit:
        mov     rbx, QWORD PTR [rsp+32]
        mov     rsi, QWORD PTR [rsp+40]
        mov     rdi, QWORD PTR [rsp+48]
        add     rsp, 88
        ret

.L23:
        sub     r14, r13
        mov     rbp, QWORD PTR [rsp+56]
        mov     r12, QWORD PTR [rsp+64]
        cmp     r14, -1
        mov     r13, QWORD PTR [rsp+72]
        mov     r14, QWORD PTR [rsp+80]
        setne   al
        jmp     .CleanUpAndExit
