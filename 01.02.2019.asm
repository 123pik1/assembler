


_zlicz_falszerstwa PROC 
push ebp
;[ebp+12] - klucz
;[ebp+8] - wejscie
mov ebp, esp
sub esp,24
;[ebp-1] - reszta z klucza
;[ebp-8] - zliczone falszerstwa
push edx
push ebx
push edi
push esi




xor eax, eax
xor ebx, ebx
mov [ebp-8], ebx
mov edi, [ebp+8]


procesowanie_jednego_elementu:
xor ebx, ebx
xor eax, eax
add edi, 10 ;pominiecie '{"tekst": '

zliczanie_elementow_tekstu:
mov al, [edi]
cmp al, ','
je zliczenie_szyfru
cmp al, 0
je koniec_programu
shr al, 1
adc ebx, 0 ;dodawanie mod 2 ze znaku
jmp zliczanie_elementow_tekstu

koniec_zliczania:

zliczenie_szyfru:
mov al, [ebp+12]
shr al, 1
adc ebx, 0 ;dodanie wartosci klucza do sumy znakow mod 2
add edi, 12 ;pominiecie: ' "szyfr" :0x'
xor eax, eax
mov al, [edi]
cmp al, 40h
ja zamien_litere_na_liczbe
sub al, 30h ;zamiana ascii w liczbę którą dany kod ascii reprezentuje
jmp cyfra1_zamieniona
zamien_litere_na_liczbe:
sub al, 41h
add al, 10 ;ustawienie wartości A na 10

cyfra1_zamieniona:

shl eax, 4 ;przemnozenie pierwszego znaku *16
movzx ecx, byte ptr [edi]
cmp ecx, 40h
ja zamien_litere_na_liczbe2
sub ecx, 30h ;zamiana ascii w liczbę którą dany kod ascii reprezentuje
jmp cyfra2_zamieniona
zamien_litere_na_liczbe2:
sub ecx, 41h
add ecx, 10 ;ustawienie wartości A na 10

cyfra2_zamieniona:
add eax, ecx ;ustalenie wartosci szyfru
cmp eax, ebx
je nie_dodawaj
mov ebx, [ebp-8]
inc ebx
mov [ebp-8], ebx
nie_dodawaj:
add edi, 2 ;pominiecie '};'
jmp procesowanie_jednego_elementu



koniec_programu:
mov eax, [ebp-8]





pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_zlicz_falszerstwa ENDP
















_znajdz_plik PROC
push ebp
mov ebp, esp
sub esp, 72
;[ebp-4] - dlugosc rootpath
;[ebp-60] - wyjscie find file
;[ebp-64] - adres nowego rootpath
;[ebp-67] - trzy znaki: pa\0
push edx
push ebx
push edi
push esi

mov [ebp-67], byte ptr 'p'
mov [ebp-66], byte ptr 'a'
mov [ebp-65], byte ptr 0


mov eax, [ebp+8]
push eax
call _SetCurrentDirectory@4

mov ebx, ebp
sub ebx, 60
push ebx
mov ebx, [ebp+12]
push ebx
call _FindFirstFileA@8
cmp eax, -1
jne znaleziono


mov ebx, ebp
sub ebx, 60
push ebx
mov ebx, ebp
sub ebx, 67
push ebx
call _FindFirstFileA@8
cmp eax, -1
je nie_znaleziono







mov eax, [ebp+8] 
push eax
call _strlen
add esp,4
mov [ebp-4], eax

add eax, 4
push eax
call _malloc
add esp,4 ;zaalokowanie pamieci na nowy rootpath
mov [ebp-64], eax

CLD
mov edi, eax
mov esi, [ebp+8]
mov ecx, [ebp-4]
REP movsb
CLD



mov ebx, [ebp-4]
mov dl, 'p'
mov [eax][ebx],dl
mov dl, 'a'
mov [eax][ebx+1], dl
mov dl, '/'
mov [eax][ebx+2],dl
mov dl,0
mov [eax][ebx+3], dl

mov ebx, [ebp+12]
push ebx
push eax
call _znajdz_plik
add esp, 8
jmp koniec

znaleziono:
mov eax, 1
jmp koniec

nie_znaleziono:
mov eax, 0
jmp koniec



koniec:
pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_znajdz_plik ENDP









_laplasjan PROC
push ebp
mov ebp, esp
sub esp, 20*4
;[ebp-9*4] - filtr
;[ebp-40] - aktualny wiersz
;[ebp-44] - aktualna kolumna
push edx
push ebx
push edi
push esi

lea ebx, [ebp-9*4]
;w ebx filtr
mov edx, [ebp+8]
;w edx obraz
xor esi, esi ;nr kolumny
xor edi, edi ;nr wiersza
;eax i ecx wolne
finit

sprawdzenie_czy_krawedz:
mov [ebp-40], edi
mov [ebp-44], esi
cmp esi,0
je krawedz
cmp edi, 0
je krawedz
mov eax, [ebp+12]
dec eax
cmp esi, eax
je krawedz
mov eax, [ebp+16]
dec eax ;numeracja od 0 (czyli jakby było 200 wierszy, to miałyby numery od 0 do 199)
cmp edi, eax
je krawedz




przeliczenie_wartosci:
fldz
;pole na skos w lewo gora x-1 i y-1
mov eax, edi
dec eax
mov esi, [ebp+12]
mul esi ;przemnozenie eax * szerokosc
add eax, esi ;dotarcie do komórki nad
dec eax ;komorka na skos w gore w lewo
mov edx, [ebp+8]
fld dword ptr [edx][eax]
lea ebx, [ebp-36]
fld dword ptr [ebx]
fmulp 
faddp ;pierwszy element z dziewieciu

inc eax
fld dword ptr [edx][eax]
fld dword ptr [ebx+1]
fmulp
faddp ;drugi arg z dziewieciu

inc eax
fld dword ptr [edx][eax]
fld dword ptr [ebx+2]
fmulp
faddp

add eax, esi
sub eax, 2
fld dword ptr [edx][eax]
fld dword ptr [ebx+4]
fmulp
faddp

inc eax
fld dword ptr [edx][eax]
fld dword ptr [ebx+5]
fmulp
faddp

inc eax
fld dword ptr [edx][eax]
fld dword ptr [ebx+6]
fmulp
faddp

add eax, esi
sub eax, 2
fld dword ptr [edx][eax]
fld dword ptr [ebx+7]
fmulp
faddp

inc eax
fld dword ptr [edx][eax]
fld dword ptr [ebx+8]
fmulp
faddp

inc eax
fld dword ptr [edx][eax]
fld dword ptr [ebx+9]
fmulp
faddp

sub eax, esi
dec eax ;dojscie do komorki w centrum
fstp [edx][eax]


krawedz:
mov edi, [ebp-40]
mov esi, [ebp-44]
inc esi
mov eax, [ebp+12]
dec eax
cmp esi, eax
je zmien_wiersz

jmp sprawdzenie_czy_krawedz

zmien_wiersz:
xor esi, esi
inc edi
mov eax, [ebp+8]
dec eax
cmp edi, eax
je koniec
jmp sprawdzenie_czy_krawedz


koniec:

pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_laplasjan ENDP