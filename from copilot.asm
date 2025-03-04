

_wyrownaj PROC
push ebp
mov ebp, esp
sub esp, 32
;[ebp-4] - adres wyrownanej tablicy
push ebx
push edi
push esi


mov eax, [ebp+16] ;zapisanie wyrownania do eax
add eax, 1
mov ecx, [ebp+12]
mul ecx

push eax
call _malloc
add esp, 4

mov [ebp-4], eax

poprawienie_eax:
xor edx, edx
mov ecx, [ebp+12]
div ecx ;w edx, reszta z dzielenia
mov edi, [ebp+16] 
sub edi, edx ;ustalenie ile trzeba dodac do eax
mov eax, [ebp-4]
add eax, edi
mov [ebp-4], eax ; zapisanie aktualnego adresu wyrownanego pod [ebp-4]



mov ecx, [ebp+12]
lea ecx, [ecx*4]
mov edi, [ebp+8]
mov esi, [ebp-4]
CLD
REP movsd ;przepisanie tablicy (8*4*4) [1 liczba] * ilosc liczb 128 bitowych



mov eax, [ebp-4]
CLD

pop esi
pop edi
pop ebx
mov esp, ebp
pop ebp
ret
_wyrownaj ENDP
