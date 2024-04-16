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


    mov edx, [operacja]

    mov al, [ecx] ;operacja
    cmp al, '+' ;jesli plus to dodawanie
    je funkcja_dodawanie_petla
    cmp al, '-' ;jesli minus to odejmowanie
    je funkcja_odejmowanie_petla
    cmp al, '*' ;jesli gwiazdka to razy
    je funkcja_mnozenie_petla


    xor edx, edx

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
    add al, 7h
    add al, '0'
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
    mov ecx, 0
    mov edi, liczba2
petla_liczba2:
    mov bl, [edi + ecx - 1]
    sub bl, '0'
    mov esi, liczba1
    mov edx, 0  ; Przeniesienie
petla_liczba1:
    ; cyfra liczby1
    mov al, [esi + edx - 1]
    sub al, '0'
    mul bl ;tutaj asm nasm akceptuje mnozenie tylko w rejestrze bl a wynik przetrzymywany jest w ax
    add al, 7h
    add al, '0'
    add al, [wynik + ecx + edx] ;dodanie iloczynu czesciowego na odpowiendia pozucje
    cmp al, 15 
    jbe bez_przeniesienia

    ; przeniesienie
    sub al, 16
    inc byte [wynik + ecx + edx + 1]
bez_przeniesienia:
    ;zapisz wynik
    add al, 7h
    add al, '0'
    mov [wynik + ecx + edx], al

    ; liczba1++
    inc edx
    cmp byte [esi + edx - 1], 0  ; czy koniec liczby1
    jne petla_liczba1

    ; liczba2++
    inc ecx
    cmp byte [edi + ecx - 1], 0  ;; czy koniec liczby2
    jne petla_liczba2


funkcja_zapisz_wynik_mnozenie:
    add al, '0'
    add al, 7h
    mov [wynik + ecx - 1], al
    mov edx, 101   
    mov ecx, wynik  
    mov ebx, STDOUT   
    mov eax, SYS_WRITE 
    int 0x80     

    call koniec        

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

    call koniec    
  
;KONIEC
koniec:
    mov eax, SYS_EXIT  
    int 0x80           