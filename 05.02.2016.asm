

_wystapienia PROC
push ebp
mov ebp, esp ;[ebp+12] - n , [ebp+8] - obszar
sub esp, 24
;[ebp-4] - adres zaalokowanej pamieci
;[ebp-8] - liczba zapisanych znakow
push edx
push ebx
push edi
push esi


mov eax, 256 * 5
push eax
call _malloc
add esp, 4
mov [ebp-4], eax
;zapisanie adresu docelowego

mov eax, 0
mov [ebp-8], eax

xor esi, esi ;counter znaku obecnie doliczanego
mov ecx, [ebp+12]
petla_glowana_zliczania
    push ecx ;aby w pętli mozna go dowolnie uzywac

    mov edi, [ebp+8] ;przepisanie adresu wejscia na rejestr
    mov dl, [edi][esi] ;przekazanie znaku do dl
    ;edi gotowe do ponownego wykorzystania
    xor ebx, ebx
    mov ecx, [ebp-8]
    znajdowanie_znaku_w_wyjscia:
    mov eax, [ebp-4]
    lea edi, [ebx*2+ebx]
    cmp dl, byte ptr [eax][edi]
    je znaleziono_znak



    inc ebx
    loop znajdowanie_znaku_w_wyjscia
    ;nie znaleziono
    mov eax, [ebp-4] ;adres wyjsciowej tablicy
    mov ecx, [ebp-8] ;liczba zapisanych znakow
    inc ecx
    mov [ebp-8], ecx
    lea ecx, [ecx+ecx*2]
    mov [eax][ecx], dl
    ; w dl caly czas jest znak szukany
    mov edi, 1
    mov [eax][ecx+1],  edi
    jmp po_zapisaniu_znaku


    znaleziono_znak:
    ;edi - adres w tablicy wskazujacy na znak
    ;eax - adres tablicy
    mov ecx, [eax][edi+1]
    inc ecx
    mov [eax][edi+1], ecx 
    ;zwiekszenie licznika znaku o 1

    po_zapisaniu_znaku:
    inc esi
    pop ecx
    dec ecx
jnz petla_glowana_zliczania


mov eax, [ebp-4] ;zapisanie w eax adresu tablicy wyjsciowej

pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_wystapienia ENDP







_sortuj PROC
push ebp
mov ebp, esp
sub esp, 24
;[ebp-4] - counter tymczasowo zapisany 
;[ebp-5] - char tymczasowo zapisany
;[ebp-12] - counter ptl1
;[ebp-16] - counter ptl2 
push edx
push ebx
push edi
push esi

mov eax, [ebp+8]
xor edx, edx
xor ebx, ebx
mov [ebp-12],edx
mov [ebp-4],edx
mov [ebp-16],edx

ptl1:
mov ebx, [ebp-12]
mov esi, [ebp+12]
dec esi
cmp ebx, esi
jnb endptl1
mov [ebp-12], ebx

ptl2:

mov ebx, [ebp-16]
mov esi, [ebp-12]
add ebx, esi
mov esi, [ebp+12]
dec esi
cmp ebx, esi
jnb endptl2


porownaj:
mov eax, [ebp+8]
mov edx, [ebp-16]

lea edx, [edx*4+edx]
mov edi, [eax][edx+1]
mov esi, [eax][edx+6]
mov edx, [ebp-16]
cmp edi, esi
jae pomin_zamiane

;zamiana dwoch sasiednich
zamien:
mov edx, [ebp-16]
lea edx, [edx*4+edx]
mov bl, [eax][edx]
mov [ebp-5], bl
mov ebx, [eax][edx+1]
mov [ebp-4], ebx
;pierwsza liczba zapisana w temp
mov bl, [eax][edx+5]
mov [eax][edx], bl
mov ebx, [eax][edx+6]
mov [eax][edx+1], ebx
;druga liczba zapisana na miejscu pierwszej
mov bl, [ebp-5]
mov [eax][edx+5], bl
mov ebx, [ebp-4]
mov [eax][edx+6], ebx
;pierwsza liczba zapisana na miejscu pierwszej




pomin_zamiane:
mov edx, [ebp-16];przywrocenie edx sprzed zamiany, w celu zamiany został pomnożony przez 5
inc edx ;zwiekszenie edx
mov [ebp-16], edx
jmp ptl2

endptl2:



mov ebx, [ebp-12]
inc ebx
mov [ebp-12], ebx ;zwiekszenie licznika petli 1
jmp ptl1
endptl1:


pop esi
pop edi
pop ebx
pop edx
mov esp, ebp
pop ebp
ret
_sortuj ENDP



_liczba_pi PROC
push EBP
mov ebp, esp
push ebx
pushe edx
push esi
push edi

mov ecx, [ebp+8]
mov eax, 2
mov edx, 1

finit
push dword ptr 2
fild [esp]
add esp, 4
petla_pi:
push eax
fild dword ptr [esp]
push edx
fild dword ptr [esp]
add esp, 8
fdivp ;podzielenie przez siebie dwoch liczb
fmulp ;przemnozenie razy wynik z poprzednich dzialan
;po kazdej iteracji stos koprocesora zawiera jedna dana - obecny wynik
cmp eax, edx
jg dodaj edx
add eax, 2
jmp dalej
dodaj edx:
add edx, 2
dalej:
loop petla_pi



;wynik zwracany przez st(0)

pop edi
pop esi
pop edx
pop ebx
mov esp, ebp
pop ebp
ret
_liczba_pi ENDP