        
        
 .model small 
.data 
    sequence       DB 100 dup(?)   ; buffer to store generated sequence          
    player_input   DB 100 dup(?)   ; buffer to store player's input 
    correct        DB 1             ; flag to track correctness of input
    level          DB 3             ; initial game level
    win_msg        DB 10,13,"CORRECT ANSWER  --- NEXT LEVEL  ", "$"
    lose_msg       DB 10,13,"WRONG ANSWER  --- END THE GAME ", "$"
    prompt_msg     DB 10,13,"TRY THE SYMBOL","$"
    exit_msg       DB 10,13,"GAME OVER! PRESS ANY KEY TO EXIT", "$"

.stack 256         ; Explicitly define stack size

.code 
    main PROC FAR
        mov ax, @data     ; Properly initialize data segment (.startup )
        mov ds, ax
        
    start_game:
        call generate_sequence    
        call display_sequence
        call get_player_input        
        call check_input             
        cmp correct, 1 
        je  next_level
        jmp game_over               

    next_level:
        lea dx, win_msg
        mov ah, 09h
        int 21h                      
        inc level                    
        cmp level, 10                ; Add maximum level check
        jl start_game
        jmp game_over
    
    game_over:
        lea dx, exit_msg             ; Added exit message
        mov ah, 09h
        int 21h
        
        mov ah, 00h                  ; Wait for key press
        int 16h
        
        mov ah, 4Ch                  ; Proper exit to DOS
        int 21h
    
    main ENDP

    generate_sequence PROC NEAR
        push cx                      ; Save registers
        push si
        
        mov al, level                ; initial value for generating the sequence
        mov ah, 0
        mov cx, ax                   ; cx register determines number of loop iterations               
        xor si, si                   ; SI register as index for storing values
    
    generate_loop:
        push cx                      ; Save loop counter
        
        ; Better random number generation
        mov ah, 00h                  ; Get system time
        int 1Ah                      ; CX:DX now contains clock ticks
        mov al, dl                   ; Use lower part of tick count
        and al, 0Fh                  ; Limit to 0-15
        add al, '0'                  ; Convert to ASCII
        
        mov [sequence + si], al      ; Store in sequence
        inc si
        
        pop cx                       ; Restore loop counter
        loop generate_loop
        
        pop si                       ; Restore registers
        pop cx
        ret
    generate_sequence ENDP

    display_sequence PROC NEAR
        push cx
        push si
        
        mov al, level
        mov ah, 0
        mov cx, ax
        xor si, si                   
    
    display_loop:
        mov al, [sequence + si]
        mov ah, 0Eh                  ; BIOS teletype output     
        int 10h                      
        inc si
        loop display_loop
        
        call delay   
        call clear_screen
        
        pop si
        pop cx
        ret
    display_sequence ENDP

    get_player_input PROC NEAR
        push cx
        push di
        
        lea dx, prompt_msg
        mov ah, 09h           
        int 21h                      
        
        mov al, level
        mov ah, 0
        mov cx, ax                  
        xor di, di                   
   
    input_loop:
        mov ah, 00h                  ; Wait for keyboard input                 
        int 16h                      
        mov [player_input + di], al  
        
        mov ah, 0Eh                  ; Display input character  
        int 10h
        
        inc di                       
        loop input_loop              
        
        pop di
        pop cx
        ret
    get_player_input ENDP       
        
        
   check_input PROC NEAR
        push cx
        push si
        push di
        
        mov al, level
        mov ah, 0
        mov cx, ax           
        xor si, si
        xor di, di
        mov correct, 1               
    
    compare_loop:
        mov al, [sequence + si]     
        cmp al, [player_input + di] 
        jne incorrect_input          
        inc si
        inc di 
        loop compare_loop
        
        pop di
        pop si
        pop cx
        ret
    
    incorrect_input:
        mov correct, 0               
        pop di
        pop si
        pop cx
        ret
    check_input ENDP
    
    delay PROC NEAR
        push cx
        push dx
        
        mov cx, 0000fh               ; Increased delay time
        
    delay_loop:
        push cx                      ; Nested loop for more reliable delay
        mov cx, 0000fh
        
    inner_delay_loop:
        nop
        loop inner_delay_loop
        
        pop cx
        loop delay_loop
        
        pop dx
        pop cx
        ret
    delay ENDP
    
    clear_screen PROC NEAR
        mov ah, 06h                  ; Scroll function
        mov al, 0                    ; Clear entire screen
        mov bh, 07h                  ; Default color attribute
        mov cx, 0                    ; Top-left corner
        mov dx, 184Fh                ; Bottom-right corner
        int 10h
        ret
    clear_screen ENDP

END main         
