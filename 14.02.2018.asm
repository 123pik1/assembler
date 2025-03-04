.686


extern _malloc

.code

_palindrom PROC
push ebp
mov ebp, esp
sub esp, 16
push edx
push ebx
push esi
push edi


;zaalokowanie pamięci na tablicę
mov ebx, [ebp+8]
xor eax, eax
liczba_znakow:
mov dx, [ebx][eax*2]
cmp dx, 0
je koniec_zliczania
inc eax
jmp liczba_znakow
koniec_zliczania

mov [ebp-4],eax ; zapisanie dlugosci w [ebp-4]

shl eax, 6
push eax
call _malloc
add esp, 4
;pamiec zaalokowana - adres w rejestrze eax
mov [ebp-8],eax



xor edi,edi
mov [ebp-12],edi
inc edi ;edi wskazuje na srodek
xor esi, esi ;esi wskazuje na aktualne przesuniecie w lewo i prawo
poczatek_szukania_palindromu:
push edi
mov esi, 1
szukanie_palindromow:
mov eax, [ebp+8] ;w eax adres tekstu
; [eax][edi]
; gdzie edi = edi - 2*esi
; lub edi = edi + 2*esi
lea edi, [edi][esi*2]
mov cx, [eax][edi]
push esi
shl esi, 2
sub edi, esi
pop esi
mov bx, [eax][edi]
cmp bx, cx
je koniec_palindromu
cmp esi, edi
je koniec_palindromu

;umiejscawianie danych w tablicy
push edi
mov ebx,[ebp-8]
mov ecx, [ebp-12]
push esi 
lea esi, [esi*2+1]
mov [ebx+4][ecx*4], esi
pop esi
lea edi, [ebx][edi]
push esi
shl esi,1
sub edi, esi


mov [ebx][ecx*4], edi

pop esi
pop edi
inc esi
inc ecx
mov [ebp-12], ecx
jmp szukanie_palindromow
koniec_palindromu:
pop edi
inc edi ; zwiekszenie edi
mov eax, [ebp+8]
mov ecx, [eax][edi]
cmp ecx, 0
jne poczatek_szukania_palindromu

mov eax, [ebp-8]


pop edi
pop esi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_palindrom ENDP











_podciag PROC
push ebp
mov ebp, esp
sub esp, 8 ; dwie zmienne: dlugosc podciagu, indeks poczatkowy
push edx
push ebx
push esi
push edi

mov ebx, [ebp+8]
mov ecx, [ebp+12]
xor edx, edx ;edx przechowuje max dlugosc
mov [ebp-4], edx
xor edi, edi
ptl1:
mov eax, [ebx][edi]
cmp eax, 0
je koniec_ptl1

push edi
xor eax, eax
xor esi, esi ;zerowanie countera tablicy nr 2
ptl2:

mov edx, [ebx][edi]
cmp edx, dword ptr [ecx][esi]

jne koniec_ptl2
inc eax

jmp ptl2
koniec_ptl2:
pop edi
mov edx, [ebp-8]
cmp eax, edx
jng dalej
mov [ebp-8], eax ;zapisanie adresu
mov [ebp-4], edi ;zapisanie adresu  podciagu


dalej:
inc edi
jmp ptl1
koniec_ptl1:
cmp edx, 1
jng wieksze
mov eax,0
jmp koniec

wieksze:
mov edx, [ebp-8]
lea edx, [edx*4]
push edx
call _malloc
add esp,4

mov ecx, [ebp-8]
mov edi, [ebp-4]
xor esi, esi
kopiowanie:
mov edx, [ebx][edi]
mov [eax][esi], edx
loop kopiowanie

koniec:
pop edi
pop esi
pop ebx
pop edx
mov esp,ebp
pop ebp
ret
_podciag ENDP





; DO ZROBIENIA 14.02.2018 zadanie nr 3




_czynnniki_pierwsze PROC
push ebp
mov ebp, esp
sub esp, 32
push edx
push ebx
push edi
push esi




mov edx, [ebp-8]
mov ecx, [ebp-12]

push ecx
push edx
call _czy_pierwsza64
add esp, 8
cmp eax, 0
je niejedno
mov edx, eax
mov ecx, 8
push ecx
call _malloc
add esp,4
mov ecx, [ebp-12]
mov ecx, [ebp-8]

niejedno:
mov ecx, -1
shr ecx, 2
push ecx
call _malloc
add esp, 4

mov [ebp-4], eax ;adres zaalakowanej tablicy
mov ecx,0
mov [ebp-8], ecx ;counter czynnikow

mov edx, [ebp-8]
mov ecx, [ebp-12]

push ecx
push edx
call _znajdz_x_y
add esp, 8

mov ecx, [ebp-8]
mov edx, [ebp-4]
jmp sprawdzenie

zapis:
mov esi, [eax]
mov [edx][ecx*4], esi
inc ecx
mov esi, [eax+4]
mov [edx][ecx*4],esi
inc ecx
mov esi, [eax+8]
mov [edx][ecx*4],esi
inc ecx
mov esi, [eax+12]
mov [edx][ecx*4],esi



sprawdzenie:
mov edx, eax
mov ebx, [ebp-8]





pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_czynnniki_pierwsze EDNP



_czy_pierwsza64 PROC
push ebp
mov ebp, esp
push edx
push ebx
push esi
push edi


mov ecx, [ebp-8]
sprawdzanie:
mov eax, [ebp-8]
mov edx, [ebp-12]
div ecx
cmp edx, 0
je nie_pierwsza
cmp ecx, 1
je nie_pierwsza
jmp sprawdzanie
mov eax, 1

nie_pierwsza:
mov eax,0

koniec:
pop edi
pop esi
pop ebx
pop edx
pop ebp
ret
_czy_pierwsza64 ENDP


_znajdz_x_y PROC ;nie przekazuje się liczby pierwszej
push ebp
mov ebp, esp
sub esp, 4
push edx
push ebx
push edi
push esi

push dword ptr 16
call _malloc
add esp,4

finit 
fild qword [ebp+8]
fld 2.0

ptl:
fmul st(0)
fld ST(1)
fsub st(1), st(0)
fsqrt 
fld st(0)
frndint 
fcomi st(0),st(1)
fstp dword ptr [ebp-4]
fstp dword ptr [ebp-4]
je koniec_ptl
fadd 1
jmp ptl


koniec_ptl:
fld st(1)
fsub st(0), st(1)
fsqrt

fstp qword ptr [eax]
fsqrt
fstp qword ptr [eax+8]



pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_znajdz_x_y ENDP




