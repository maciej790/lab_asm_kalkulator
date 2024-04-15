;nauczyc sie kodu dzielenie
;pomeczyc moze jeszcze troche to dzielenie - hex
;zrobic sprawko z dzielenia
;zlepic calosc
;nauczuc sie calosci
;kod cpp (przerobic) + lista krokow

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

;funkcje
funkcja_dzielenie:
    ; Inicjalizacja licznika
    xor ecx, ecx
    
    ; Przygotowanie do pętli dzielenia
    mov esi, liczba1 ; Pierwsza liczba
    mov edi, liczba2 ; Druga liczba

    sub esi, '0'
    sub edi, '0'

    ; Inicjalizacja wyniku
    mov ebx, wynik
    mov byte [ebx], '0' ; Ustaw pierwszą cyfrę wyniku na zero
    inc ebx

dzielenie_nastepna_cyfra:
    ; Przygotowanie do sprawdzenia, czy kolejna cyfra może być dodana do wyniku
    mov eax, dword [esi + ecx] ; Wczytaj kolejne 4 bajty z pierwszej liczby

    ; Sprawdź, czy jest możliwe dodanie kolejnej cyfry do wyniku
    cmp eax, 0
    je dzielenie_wynik

    ; Dodaj kolejną cyfrę do wyniku
    add ebx, ecx
    mov dword [ebx], eax

    ; Przygotowanie do przesunięcia reszty
    mov edx, 0

dzielenie_podzial:
    ; Sprawdź, czy reszta jest większa lub równa drugiej liczbie
    cmp edx, dword [edi]
    jb dzielenie_podzial_koniec

    ; Oblicz nową cyfrę wyniku i resztę
    inc byte [ebx]
    sub edx, dword [edi]

    ; Powtórz, dopóki reszta jest większa lub równa drugiej liczbie
    jmp dzielenie_podzial

dzielenie_podzial_koniec:
    ; Przygotuj się do kolejnej iteracji
    add ecx, 4 ; Przesunięcie do kolejnej cyfry
    inc ebx ; Przesunięcie do kolejnej cyfry wyniku
    xor edx, edx ; Wyzeruj resztę

    ; Przygotowanie do sprawdzenia, czy jest możliwe dodanie kolejnej cyfry do wyniku
    cmp ecx, 100 ; Zakładając, że liczba1 ma maksymalnie 100 cyfr
    jl dzielenie_nastepna_cyfra

dzielenie_wynik:
    ; Wyświetlenie wyniku
    mov al, [wynik]
    add al, '0'
    add al, 7h ; Dodaj 7h, aby przekształcić cyfrę w systemie szesnastkowym
    mov edx, 101 ; Liczba cyfr do wyświetlenia
    sub edx, wynik ; Odejmij wskaźnik początkowy od końcowego, aby uzyskać długość
    mov ecx, wynik
    mov ebx, STDOUT   
    mov eax, SYS_WRITE 
    int 0x80     

    ; Wyjście
    mov eax, SYS_EXIT  
    int 0x80