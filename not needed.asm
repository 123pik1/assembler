; Piotr Kaczorowski 197736

.686
.model flat
.xmm
;public _szukaj4_max
;public _plus_jeden
;public _odejmij_jeden
public _min_abs
public _test
public _srednia_wazona
public _wystapienia

extern _malloc : PROC

.data
minus dd -1
bufor db 'abcd',10 dup (?)
.code

_liczba_pi PROC
push ebp
mov ebp, esp
push ebx
push edx
push esi
push edi

mov ecx, [ebp+8]
mov ebx,2
mov edx,1
finit
fld 2.0
ptl:
    push ebx
    fild dword ptr [ebx]
    pop ebx
    push edx
    fild dword ptr [edx]
    pop edx
    fdivp
    fmulp
    cmp ebx,edx
    jb ebx_mniejsze
    add edx,2
    loop ptl
    ebx_mniejsze:
    add ebx,2
    loop ptl




koniec:
pop edi
pop esi
pop edx
pop ebx
pop ebp

ret
_liczba_pi ENDP





_sortuj PROC
push ebp
mov ebp, esp
push ebx
push edx
push esi
push edi

mov ecx, [ebp+12]
xor ebx, ebx
xor edi, edi
xor esi, esi
mov edx, [ebp+8]

ptl_glowna:
    xor esi, esi
    mov ebx, [edx][esi+1]
    push ecx
    ptl:

        mov edi, [edx][esi+6]
        cmp ebx, edi
        jb zamien

        kontynuuj:
            add esi,5
    loop ptl
    pop ecx
loop ptl_glowna


jmp koniec

zamien:
    push ebx
    push edi
    push eax
    mov bl, [edx][esi]
    mov edi,[edx][esi+1]
    mov bh, [ecx][esi+5]
    mov eax,[ecx][esi+6] 
    mov [edx][esi+5], bl
    mov [edx][esi+6], edi
    mov [ecx][esi], bh
    mov [ecx][esi+1], eax
    pop eax
    pop edi
    pop ebx
jmp kontynuuj


koniec:
pop edi
pop esi
pop edx
pop ebx
pop ebp

ret
_sortuj ENDP





_wystapienia PROC
push ebp
mov ebp, esp
push ebx
push edx
push esi
push edi

mov eax, [ebp+12]

lea eax, [eax+eax*4] 
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
_wystapienia ENDP










_srednia_wazona PROC ; double tablica danych, double tablica wag, int liczba obrotow petli
push ebp
mov ebp,esp
push ebx
push esi
push edi

mov ebx,[ebp+8] ; adres tablicy danych
mov ecx,[ebp+12] ; adres tablicy wag
mov edx,[ebp+16] ; liczba obrotow petli


finit

fldz ; zerowanie sumy
; 0
fldz ; zerowanie sumy wag
; 0,0

ptl:
    fld qword ptr [ebx] ; wczytanie pierwszej liczby
    fld qword ptr [ecx] ; wczytanie pierwszej wagi
    ; waga, liczba, suma, suma wag
    fadd ST(3), sT(0) ; dodanie wagi do sumy wag
    fmul ST(0), ST(1) ; pomnozenie liczby przez wage
    faddp ST(2), ST(0) ; dodanie wyniku do sumy
    ; liczba, suma, suma wag
    fstp ST(0) ; usuniecie liczby
    ; suma, suma wag

    add ebx,8 ; przesuniecie adresu tablicy danych
    add ecx,8 ; przesuniecie adresu tablicy wag
    ; liczba, waga, wynik,suma wag
    


    

dec edx
cmp edx,0
jnz ptl



fdiv ST(0), ST(1) ; podzielenie sumy przez sume wag


pop edi
pop esi
pop ebx
pop ebp
ret
_srednia_wazona ENDP




_test PROC

mov dl,bufor[EAX]-1
ret
_test ENDP



_min_abs PROC
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov ebx, [ebp + 8] ; adres tablicy
    mov ecx, [ebp + 12] ; liczba obrotów petli
    mov esi, 0 ; index akt min
    mov edi, 2147483647 ; aktualna min wartosc bezwzgledna
    mov edx, ecx ; rozmiar

petla:
    mov eax, [ebx] ; wczytanie liczbe
    add ebx, 4 ; przesuniece adresu tablicy na kolejna liczbe
    cmp eax, 0
    jl zmiana_znaku ; jesli ujemna to zmien znak
    jmp min_porownanie 

    zmiana_znaku:
    push edx ; zapamietywanie edx przed mnozeniem
    mov edx, 0
    mul minus
    pop edx

    min_porownanie:
    cmp eax, edi
    jb min_aktualizowanie
    jmp koniec

    min_aktualizowanie:
    mov edi, eax ; aktualizowanie minimalnej wartosci bezwzglednej

    mov esi, edx
    sub esi, ecx 

    koniec:
    loop petla

    mov ebx, [ebp + 8] ; ustawienie ebx na poczatek tablicy
    mov eax, [ebx + 4*esi] ; zapisanie w eax wyniku

    pop edi
    pop esi
    pop ebx
    pop ebp
    ret
_min_abs ENDP
END
_create_benford_distribution PROC
push ebp
mov ebp, esp
push ebx
push edx
push esi
push edi

push dword ptr 1
push dword ptr 1000h
push dword ptr 9*4 ; wielkość
push dword ptr 0
call VirtualAlloc@16 ; zaalokowanie pamieci

;adres tablicy w eax

xor ebx,ebx

finit 
mov ecx, 9

ptl:
fld1
fld1
inc ebx
push ebx
fild dword ptr [esp]
pop ebx
;wrzucenie do koproc ebx+1 i powrót ebx do początkowej wartości
fdivp
faddp
fld1
fyl2x
;log2(1+1/k)
fld1
push dword ptr 10
fild dword ptr[esp]
pop edx
fyl2x
fdivp
fstp dword ptr [eax][ebx*4]
dec ecx
jnz ptl




koniec:
pop edi
pop esi
pop edx
pop ebx
pop ebp

ret
_create_benford_distribution ENDP


_get_actual_distribution PROC
push ebp
mov ebp, esp
push ebx
push edx
push esi
push edi



mov edx,[ebp+12]
push edx
call _build_table
add esp,4
; w eax zaalakowany obszar

mov ecx, [ebp+12]
mov edi, [ebp+8]
dec ecx,1
ptl1:

movzx ebx, word ptr [edi]
add edi, 2  
sub ebx,31
mov edx, [eax][ebx]
inc edx
mov dword ptr [eax][ebx],edx ;zwiekszenie licznika o 1



ptl2: ;przejscie po reszcie cyfr
movzx ebx, word ptr [edi]
add edi, 2  
cmp ebx, 2ch
je koniecpetli1
cmp ebx, 0
je koniecpetli1
jmp ptl 2




koniecpetli1:
dec ecx
jnz ptl



;zamienic na floaty
finit
move edx, dword ptr [ebp+12]
dec edx
push edx
fild dword ptr [esp]
pop edx
mov ecx, 9
xor ebx, ebx
ptlFLOAT:
fild dword ptr [eax][ebx]
fdiv st(0), st(1)
fstp dword ptr [eax][ebx]
add ebx,4
loop ecx

;w eax sa zliczone pierwsze cyfry ciagów znaków



koniec:
pop edi
pop esi
pop edx
pop ebx
mov esp, ebp
pop ebp

ret
_get_actual_distribution ENDP

_check_data PROC
push ebp
mov ebp, esp
push ebx
push edx
push esi
push edi


mov edx, [ebp+8]
xor ecx,ecx
xor ebx,ebx
counting:
    add ecx,2
    movzx eax, word ptr [edx][ecx]
    cmp eax, ','
    je dodaj
    cmp eax,'0'
    je dalej
    jmp counting
    dodaj:
    inc ebx
    jmp counting

dalej:
inc ebx
push ebx
push edx
call _get_actual_distribution
add esp, 8
mov edi, eax ; actal_dist w edi

call _create_benford_distribution
;benford dist w eax


xor esi,esi
finit
push dword ptr o.125
fld [esp]
pop ecx
mov ecx, 9 ;ustawienie iteracji po tablicy

ptl:
fld dword ptr [eax][esi]
fld dword ptr [edi][esi]
fsubp
fabs
fcomi str(0),st(1)
ja sfalszowane
loop ptl
mov eax,0
jmp koniec
sfalszowane:
mov eax,1





koniec:
pop edi
pop esi
pop edx
pop ebx
mov esp, ebp
pop ebp

ret
_check_data ENDP