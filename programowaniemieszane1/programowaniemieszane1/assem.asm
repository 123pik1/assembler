.686
.model flat



extern _malloc : PROC
extern _VirtualAlloc@16 : PROC
extern _build_table : PROC

.data
tablica_kodowa dd ?
liczba_wierszy dd 0


.code

_get_rpk PROC
push ebp
mov ebp, esp
push ebx
push edx
push esi
push edi




dalej:





jmp koniec
decoding: ;ebx - znak



koniec:
pop edi
pop esi
pop edx
pop ebx
mov esp, ebp
pop ebp

ret
_get_rpk ENDP


_shl_128 PROC
push ebp
mov ebp,esp
push ebx
push edx
push esi
push edi

mov eax, [ebp+8]
mov ecx, [ebp+12]

mov ebx, [eax]
mov edx, [eax+4]
mov edi, [eax+8]
mov esi, [eax+12] ;przepisanie liczby do rejestrów: esi:edi:edx:ebx

ptl:
shl ebx,1
rcl edx,1
rcl edi,1
rcl esi,1
loop ptl

mov [eax], ebx
mov [eax+4], edx
mov [eax+8], edi
mov [eax+12], esi


pop edi
pop esi
pop edx
pop ebx
mov esp, ebp
pop ebp
ret
_shl_128 ENDP

__mul24 PROC
push ebp
mov ebp, esp
sub esp, 32
push edx
push ebx
push edi
push esi

mov eax, [ebp+8]
mov ebx, [ebp-32]
mov ecx, [eax]
mov [ebx], ecx
mov ecx, [eax+4]
mov [ebx+4], ecx
mov ecx, [eax+8]
mov [ebx+8], ecx
mov ecx, [eax+12]
mov [ebx+12], ecx
; skopiowanie liczby po raz pierwszy

mov ebx, [ebp-16]
mov ecx, [eax]
mov [ebx], ecx
mov ecx, [eax+4]
mov [ebx+4], ecx
mov ecx, [eax+8]
mov [ebx+8], ecx
mov ecx, [eax+12]
mov [ebx+12], ecx
; skopiowanie liczby po raz drugi

mov edi, 3
push edi
push ebx
call _shl_128
add esp,8


mov ebx, [ebp-32]
mov edi, 4
push edi
push ebx
call _shl_128
add esp, 8




;trzeba zsumować te 2 liczby
mov eax, [ebp+12]
mov ecx, [ebp-32]
add ecx, dword ptr [ebp-16]
mov [eax], ecx

mov ecx, [ebp-28]
adc ecx, dword ptr [ebp-12]
mov [eax+4], ecx

mov ecx, [ebp-24]
adc ecx, dword ptr [ebp-8]
mov [eax+8], ecx

mov ecx, [ebp-20]
adc ecx, dword ptr [ebp-4]
mov [eax+12], ecx

;cf jest ustawiony jeżeli wyszło poza zakres





pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
__mul24 ENDP


_mul64 PROC
push ebp
mov ebp, esp
push ebx
push edx
push esi
push edi

;pierwsza liczba (od najstarszej czesci bajtu):   [ebp+12][ebp+8]
;druga liczba:                                    [ebp+20][ebp+16]

;wynik będzie przetrzymywany w rejestrach: esi:edi:ebx:ecx
;na praktyce uwzględniałem znak, a nie powinienem
;wynik jest zwracany w xmm0
xor esi, esi
xor edi, edi
xor ebx, ebx
xor ecx, ecx ; wyzerowanie rejestrów


mov eax, [ebp+8]
mov edx, [ebp+16]

mul edx

mov ecx, eax
mov ebx, edx
;mnożenie nr 1 pionowe

mov eax, [ebp+12]
mov edx, [ebp+20]

mul edx

add ebx, eax
adc edi, edx
;mnożenie nr 2 po skosie (doł lewo, prawo góra)

mov eax, [ebp+8]
mov edx, [ebp+16]

mul edx

add ebx, eax
adc edi, edx
adc esi, 0
;mnożenie nr 3 po skosie (dół prawo, lewo góra)

mov eax, [ebp+12]
mov edx, [ebp+20]

mul edx

add edi, eax
adc esi, edx
;mnożenie nr 4

;wrzucenie wyniku do xmm0
push esi
push edi
push ebx
push ecx

movaps xmm0, [esp]
add esp, 16



pop edi
pop esi
pop edx
pop ebx
mov esp, ebp
pop ebp
ret
_mul64 ENDP



_gen_xi PROC
push ebp
mov ebp, esp
sub esp,16
push edx
push ebx
push edi
push esi

mov ecx, [ebp+8]
dec ecx
mov eax, [ebp+16]


cmp ecx, 0
je pomin_rek
push ecx
push eax
call _gen_xi
add esp, 8
jmp dalej

pomin_rek:

dalej:
mov eax, [ebp+16]
mov ebx, A2E7B175h ;młodsza
mov ecx, 2875h ;starsza
mov edi, [eax] ;młodsza
mov esi, [eax+4];starsza

push ecx
push ebx
push esi
push edi
call _mul64
add esp, 16
;odtąd miałem źle i pominałem wartość xi w najwiekszym zaglebieniu rekurencji

movaps [ebp-16], xmm0

mov ecx, [ebp-16]
mov [eax], ecx
mov ecx, [ebp-12]
shl ecx, 16
shr ecx, 16
mov [eax+4], ecx



pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_gen_xi ENDP


_salt PROC
push ebp
mov ebp, esp
sub esp, 264
push ebx
push esi
push edi

mov eax, [ebp+8]
push eax
call _dlugosc
add esp, 4

mov [ebp-264], eax
lea eax, [ebp-256]
lea ecx, [ebp-260]

push ecx
push eax
call _GetComputerNameA@8

xor edi, edi
znajdz_przedostatni_znak:
mov al, [ebp-256][edi]
cmp al, 0
je koniec_szukania
inc edi
jmp znajdz_przedostatni_znak

koniec_szukania:
dec edi
mov al, [ebp-256][edi]
mozx eax, al

finit

push eax
fild [esp]
fptan
fdivp
FABS
add esp,4
;tangens na st(0)
fld [ebp+12]
fmulp
mov eax, 2.56
push eax
fld [esp]
add esp,4
fdivp
fstp [ebp-4]

;liczba 64bit bedzie: esi:edi (edi młodsze bajty)
xor esi, esi
mov edi, [ebp-4]
mov ecx, [ebp-264]
CLC
ptl:
rcl edi,1
rcl esi,1
loop ptl


mov edx, esi
mov eax, edi


pop edi
pop esi
pop ebx
mov esp, ebp
pop ebp
ret
_salt ENDP

_dlugosc PROC
push ebp
mov ebp, esp
push edx

xor eax, eax
mov ecx, [ebp+8]
ptl:
mov dx, word ptr [ecx][eax*2]
cmp dx, 0
je koniec
inc eax
jmp ptl


koniec:
pop edx
mov esp, ebp
pop ebp
ret
_dlugosc ENDP


END