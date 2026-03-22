; in:
;   rcx = src1 pointer
;   rdx = src2 pointer
;   r8  = len
memcmp:
    sub     rdx, rcx ; rdx is now just the signed difference from memory pointer 1 to memory pointer 2; this way you only have to increment pointer 1
    cmp     r8, 8
    jb      CompareByteByByte
    test    cl, 7
    je      Src8byteAligned
    nop
CompareUntilAligned:
    ; okay so we know the length is >= 8, but the src pointer isn't 8-byte aligned YET, let's just do old-fashioned byte-by-byte comparisons until it is
    mov     al, byte ptr [rcx]
    cmp     al, byte ptr [rcx+rdx]
    jne     ReturnDiff
    inc     rcx
    dec     r8
    test    cl, 7
    jne     CompareUntilAligned
    ; fall thru
Src8byteAligned:
    mov     r9, r8
    shr     r9, 3 ; len / 8
    jne     OptimizedChecks ; check if len is still >= 8 after the CompareUntilAligned loop (and in the process, knock 3 out of 5 shifts out of the way for the next part where it checks if len > 32)
CompareByteByByte:
    test    r8, r8
    je      ReturnSame
Below8CheckLoop:
    mov     al, byte ptr [rcx]
    cmp     al, byte ptr [rcx+rdx]
    jne     ReturnDiff
    inc     rcx
    dec     r8
    jne     Below8CheckLoop
ReturnSame:
    xor     rax, rax
    ret
ReturnDiff:
    sbb     eax, eax
    sbb     eax, 0FFFFFFFFh
    ret
OptimizedChecks:
    nop
    shr     r9, 2 ; len / 32
    je      LenBelow32
CompareQwordByQword:
    mov     rax, qword ptr [rcx]
    cmp     rax, qword ptr [rcx+rdx]
    jne     WeirdReturnDiff
    mov     rax, qword ptr [rcx+8]
    cmp     rax, qword ptr [rcx+rdx+8]
    jne     WeirdReturnDiffAdd8
    mov     rax, qword ptr [rcx+10h]
    cmp     rax, qword ptr [rcx+rdx+10h]
    jne     WeirdReturnDiffAdd16
    mov     rax, qword ptr [rcx+18h]
    cmp     rax, qword ptr [rcx+rdx+18h]
    jne     WeirdReturnDiffAdd24
    add     rcx, 20h
    dec     r9
    jne     CompareQwordByQword
    and     r8, 1Fh
LenBelow32:
    mov     r9, r8
    shr     r9, 3
    je      CompareByteByByte
CompareRemainingQwords:
    mov     rax, qword ptr [rcx]
    cmp     rax, qword ptr [rcx+rdx]
    jne     WeirdReturnDiff
    add     rcx, 8
    dec     r9
    jne     CompareRemainingQwords
    and     r8, 7
    jmp     CompareByteByByte
WeirdReturnDiffAdd24:
    add     rcx, 8
WeirdReturnDiffAdd16:
    add     rcx, 8
WeirdReturnDiffAdd8:
    add     rcx, 8
WeirdReturnDiff:
    mov     rcx, qword ptr [rdx+rcx]
    bswap   rax
    bswap   rcx
    cmp     rax, rcx
    sbb     eax, eax
    sbb
    ret
