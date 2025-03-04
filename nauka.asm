.686
model flat

extern _malloc


#void *wystapienia(void *obszar, unsigned int n);
_wystapienia PROC
push ebp
move ebp, esp
push ebx
push edx
push esi
push edi

mov eax, [ebp+8]

lea eax, [eax+eax*4] //multiply by 5
push eax
call _malloc
add esp, 4
mov ebx, [ebp+8]
ptl:
    mov edi,0
    mov cl, [ebx]
    mov esi, ebx
        counting:
        cmp cl, byte PTR [esi]
        jne dalej
        inc edi
        dalej:
        inc esi
        push eax
        mov eax,[ebp+8]
        add eax,[ebp+12]
        cmp eax, esi
        pop eax
        jne counting
    mov [eax],cl
    mov [eax+1],edi
    add eax,5
    push eax
    mov eax,[ebp+8]
    add eax,[ebp+12]
    cmp eax, esi
    pop eax
    jne ptl
koniec:
pop edi
pop esi
pop edx
pop ebx
pop ebp

ret
ENDP