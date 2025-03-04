.data
tablica_kodowa dd ?
liczba_wierszy dd 0

.code
_wypelnij_tablice_kodowa  PROC
push ebp
mov ebp, esp


mov eax, 256
mul dword ptr 3
push eax
call _malloc
add esp, 4

mov tablica_kodowa, eax

mov eax, 0
push eax
push eax
push dword ptr [ebp+8]
call _sprawdz_wezel
add esp,12


mov esp, ebp
pop ebp
ret
_wypelnij_tablice_kodowa ENDP

_sprawdz_wezel PROC ;parametry: wezel [ebp+8], ciag dotychczasowych znakow [ebp+12], dlugosc [ebp+16]
push ebp
mov ebp, esp
push edx
push ebx
push esi
push edi

mov edx, [ebp+8]
mov al, [edx+2]
cmp al, -1
jne litera_znaleziona

;przejscie w prawo
mov eax, [ebp+16]
inc eax
push eax ;dlugosc ciagu, spushowana
mov eax, [ebp+12]
stc
rcl eax, 1
push eax ; dotychczasowy ciag znakow spushowany
mov eax, [ebp+8]
push dword ptr [eax+4]
call _sprawdz_wezel
add esp, 12


;przejscie w lewo
mov eax, [ebp+16]
inc eax
push eax ;dlugosc ciagu, spushowana
mov eax, [ebp+12]
clc
rcl eax, 1
push eax ; dotychczasowy ciag znakow spushowany
mov eax, [ebp+8]
push dword ptr [eax]
call _sprawdz_wezel
add esp, 12

jmp koniec
litera_znaleziona:
mov ebx, tablica_kodowa
mov ecx, liczba_wierszy
inc ecx 
mov liczba_wierszy, ecx
dec ecx
lea ecx, [ecx*2+ecx] ; ecx nr komórki

mov [ebx+ecx], al
mov eax, [ebp+12]
mov [ebx+ecx+1], al
mov eax, [ebp+16]
mov [ebx+ecx+2], al
; zapisanie wartosci do tablicy


koniec:
pop edi
pop esi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_sprawdz_wezel ENDP




















_kompresuj PROC
push ebp
mov ebp, esp
sub esp, 24 
; [ebp-4] - counter odczytanych znakow
; [ebp-8] - aktualna zapamietana dlugosc w bitach
; [ebp-12] - aktualnie zapamietywany bajt
push edx
push ebx
push edi
push esi

mov eax, 0
mov [ebp-4], eax
mov [ebp-8], eax
mov [ebp-12], eax


mov eax, [ebp+12]
push eax
call _malloc
add esp, 4

mov [ebp+16], eax ;zapisanie tablicy w wyjsciu


mov ecx, [ebp+12]
petla_glowana_kompresji:
push ecx
znajdz_znak:
mov edi, [ebp+8] 
xor edx, edx
mov esi, [ebp-4]
mov al, [edi][esi]
petla_w_znajdz_znak:
mov bl, [edx*2+edx+tablica_kodowa] ;dostanie sie do wartosci aktualnie sprawdzanego znaku - rozmiar wiersza w tablicy to 3 bajty
cmp bl, al
je znaleziono_znak
inc edx
jmp petla_w_znajdz_znak

znaleziono_znak:
lea edx, [edx*2+edx] ;przemnozenie edx dla wygody *3
mov al, [edx+tablica_kodowa+1] ; dostanie sie do bajtu ktory zawiera kod liczby
movzx ecx, byte ptr [edx+tablica_kodowa+2] ;zapisanie w ecx dlugosci tego ciagu
; okreslenie liczby wykonywania petli

przesuniecie_bitowe_do_zapamietania_bajtu:
mov esi, [ebp-8]
shr esi, 3 ;dlugosc bajtow zapisanych (bitow/8)
mov ebx, [ebp+16]
;edx juz sie nie przyda - mozna uzyc ponownie
add ebx, esi ; okreslenie bajtu na ktorym sie dziala z wyjscia
mov dl, [ebx] ; bajt do edycji w dl
shr al,1
rcl dl, 1
inc esi
mov [ebx], dl
mov [ebp-8], esi
loop przesuniecie_bitowe_do_zapamietania_bajtu 
pop ecx
sub ecx, 1
jnz petla_glowana_kompresji


mov eax, [ebp-8]
shr eax, 3


koniec:
pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_kompresuj ENDP













_float_to_F24P PROC
push ebp
mov ebp, esp
push edx
push ebx
push esi
push edi

mov eax, [ebp+8]    
mov ebx, eax ;skopiowanie floata
shl eax, 1 ;usuniecie bitu znaku - jako jedyny moze byc rozny od 1 dla 0

cmp eax, 0
je zerowa_wartosc
mov eax, [ebp+8]
mov ecx, 64
shl ecx, 23

sub eax, ecx ;odjecie 64 od mantysy

bt eax, 31
jc znak_nieujemny
bts eax, 30

znak_nieujemny:
;w eax jest float 31 bitowy - 1 bit znaku, 7 bitow wykladnika, 23 mantysy
;zamiana w eax na 24 bitowy F24P
shr eax, 7

jmp koniec

zerowa_wartosc:
mov eax, [ebp+8]
bt eax, 31
jc znak_nieujemny
bts eax, 30
shr eax, 7


koniec:
pop edi
pop esi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_float_to_F24P ENDP