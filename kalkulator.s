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
    mov ecx, operacja
    mov edx, 2
    int 0x80 

    mov eax, SYS_READ  
    mov ebx, STDIN  
    mov ecx, liczba2
    mov edx, 100
    int 0x80   

    mov al, [ecx] ;operacja
    cmp al, '+' ;jesli plus to dodawanie
    je funkcja_dodawanie_petla
    cmp al, '-' ;jesli minus to odejmowanie
    je funkcja_odejmowanie_petla
    cmp al, '*' ;jesli gwiazdka to razy
    je funkcja_mnozenie_petla

    mov esi, liczba1
    mov edi, liczba2  
    mov ecx, 100

;funkcje
funkcja_dodawanie_petla:
    mov al, [esi + ecx - 1]  
    sub al, '0'     
    add al, [edi + ecx - 1]   
    sub al, '0'   
    
    cmp al, 15 ;sprawdzenie czy wynik nie przekroczyl 15 - maksymalny wynik dodawania w szesnastkowym
    jbe funkcja_zapisz_wynik_dodawanie  ;jesli nie    

    sub al, 16
    add al, 7h
    add al, '0'
    inc byte [esi + ecx - 1] ;przenieseinie +1 

funkcja_zapisz_wynik_dodawanie:
    add al, 7h      ;konwersja na hex prawdopodobnie zle konwertuje do poprawy
    add al, '0'     ;ascii
    mov [wynik + ecx - 1], al
    dec ecx ; -1
    jnz funkcja_dodawanie_petla ;dopoki !=0

    mov edx, 101     
    mov ecx, wynik 
    mov ebx, STDOUT     
    mov eax, SYS_WRITE     
    int 0x80

    call koniec    

funkcja_odejmowanie_petla:
    mov al, [esi + ecx - 1]   ;zapisz najmlodzy bit - przesuniecie
    sub al, '0'               
    mov bl, [edi + ecx - 1]   
    sub bl, '0'              

    cmp al, bl                
    jl pozyczka  ;jesli cyfra 1 mneijsza - pozuczka    

    sub al, bl 
    add bl, 7h
    add al, '0'               
    jmp funkcja_zapisz_wynik_odejmowanie        

pozyczka:
    add al, 16            
    sub al, bl                
    add al, 7h 
    add al, '0'
    dec byte [esi + ecx - 1] ;pozyczam z nastepnej pozycji -1                   

funkcja_zapisz_wynik_odejmowanie:
    mov [wynik + ecx - 1], al  ; Zapisz wynik
    dec ecx                     ; Przejdź do poprzedniej cyfry
    jnz funkcja_odejmowanie_petla           ; Jeśli nie, kontynuuj odejmowanie

    mov edx, 101   
    mov ecx, wynik  
    mov ebx, STDOUT   
    mov eax, SYS_WRITE 
    int 0x80     

    call koniec 

funkcja_mnozenie_petla:
    mov al, [esi + ecx - 1] 
    sub al, '0'     
    cmp al, 0         ; sprawdzam czy koniec liczby1
    je koniec_mnozenia  ; jesli tak koniec mnozenia   

    mov bl, [edi + ecx - 1]
    cmp bl, 0         ; sprawdzam czy koniec liczby2
    je koniec_mnozenia  ; jesli tak   koniec mnozenia   

    mul bl; tutaj asm nasm akceptuje mnozenie tylko w rejestrze bl a wynik przetrzymywany jest w ax
    add al, 7h ;konwersja na hex

    ;tutaj powinno byc dodawanie sekwencyjne bit po bicie z przesuneciem
    ;niestety brak pomyslu
    ;stad sumowanie tylko wyniku czesciowego mnozenia bez przesuniecia 
    add [wynik + ecx - 1], ax 

    inc esi
    inc edi

koniec_mnozenia:
    add al, 7h ;konwersja na hex
    call funkcja_zapisz_wynik_mnozenie
funkcja_zapisz_wynik_mnozenie:
    mov [wynik + ecx - 1], al  ; Zapisz wynik
    dec ecx                     ; Przejdź do poprzedniej cyfry
    jnz funkcja_mnozenie_petla   ; Jeśli nie, kontynuuj mnozenie

    mov edx, 101   
    mov ecx, wynik  
    mov ebx, STDOUT   
    mov eax, SYS_WRITE 
    int 0x80     

    call koniec     

;KONIEC
koniec:
    mov eax, SYS_EXIT  
    int 0x80           

;mnozenie jest zle napisane - brak zaimplementowanego dodawania sekwencyjnego + jednak zla konwersja na hex - raport
;bledy i ich interpretacja i/lub ewentualna propozycja naprawy beda zawarte w raporcie na gh lub pdf do oddania