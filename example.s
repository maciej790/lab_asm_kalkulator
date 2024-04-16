SYS_EXIT  equ 1
SYS_READ  equ 3 ;czytaj
SYS_WRITE equ 4 ; zapisz
STDIN     equ 0 ;wejście
STDOUT    equ 1 ;wyjście

section .data
section .bss 
    liczba1 resb 100
    liczba2 resb 100
    operacja resb 2
    wynik resb 101

section .text
global _start

_start:
    mov eax, SYS_READ  
    mov ebx, STDIN  
    mov ecx, liczba1
    mov edx, 100
    int 0x80

    mov eax, SYS_READ  
    mov ebx, STDIN  
    mov ecx, liczba2
    mov edx, 100
    int 0x80

    mov esi, liczba1
    mov edi, liczba2  
    mov ecx, 100

funkcja_dzielenie:
    xor ecx, ecx
    
    mov esi, liczba1 
    mov edi, liczba2 

    sub esi, '0'
    sub edi, '0'

    ; najnstarszy bit wyniku przesun na zero
    mov ebx, wynik
    mov byte [ebx], '0' 
    inc ebx ;inkrementacja miejsca w wyniku

dzielenie_nastepna_cyfra:
    ; czy mozna dodac kolejna cyfre do wyniku
    mov eax, dword [esi + ecx] ; wczytaj kolejne 4 bity z pierwszej liczby

    ;czy mozna dodac koljna cyfre do wyniku
    cmp eax, 0
    je dzielenie_zapisz_wynik

    ; dodaj kolejną cyfrę do wyniku
    add ebx, ecx
    mov dword [ebx], eax

    ; przygotowanie do przesuniecia reszty
    mov edx, 0

dzielenie_reszta:
    ;czy reszta >= liczba2
    cmp edx, dword [edi]
    jb dzielenie_reszta_koniec

    ;nowa cyfra wyniku i reszta
    inc byte [ebx]
    sub edx, dword [edi]

    ; dopoki reszta >= liczba2
    jmp dzielenie_reszta

dzielenie_reszta_koniec:
    ; kolejna iteracja
    add ecx, 4 ;przesuwun 4 w prawo (bajt)
    inc ebx ; przesunięcie do kolejnej cyfry wyniku
    xor edx, edx ; wyzeruj resztę

    ; czy mozna dodac koljna cyfre do wyniku
    cmp ecx, 100
    jl dzielenie_nastepna_cyfra

dzielenie_zapisz_wynik:
    ; Wyświetlenie wyniku
    mov al, [wynik]
    add al, '0'
    add al, 7h ; Dodaj 7h, aby przekształcić cyfrę w systemie szesnastkowym
    mov edx, 101
    mov ecx, wynik
    mov ebx, STDOUT   
    mov eax, SYS_WRITE 
    int 0x80     

    mov eax, SYS_EXIT  
    int 0x80