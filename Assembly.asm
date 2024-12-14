.model small 
.data 
    sequence       DB 100 dup(?)   ; output return the screan          
    player_input   DB 100 dup(?)   ; input user your sequuence 
    correct        DB 1                
    level          DB 3
    win_msg        DB 10,13,"CORRECT ANSWER  --- NEXT LEVEL  ", "$"
    lose_msg       DB 10,13,"WRONG ANSWER  --- End THE GAME ","$"
    prompt_msg     DB 10,13,"TRY THE SYMBOL","$"

.code 
    main proc far 
    .startup 
    start_game:
    call generate_sequence    
    call display_sequence
    call get_player_input        
    call check_input             
    cmp correct, 1 
    je  next_level
    jne game_over               

next_level:
    lea dx, win_msg
    mov ah, 09h
    int 21h                      
    inc level                    
    jmp start_game  
game_over:
    lea dx, lose_msg
    mov ah, 09h
    int 21h            
    
    .exit   ; mov ah, 4Ch  int 21h 
    
    
    
    
    generate_sequence proc 

    mov al, level ;initial value for generating the sequence
    mov ah, 0
    mov cx, ax  ;cx register determines the number of loop iterations               
    xor si, si  ;SI register will be used as an index for storing values in memory
    
    generate_loop:
    in al,40h    
    and al, 0Fh                
    add al, '0' ;This converts the number (0?15) into its ASCII character representation ('0'?'F').                
    mov [sequence + si], al ;Stores the generated ASCII character into memory at the address sequence + si    
    inc si ; to move to the next memory location in the sequence buffer
    loop generate_loop
    ret
        generate_sequence endp


        
    display_sequence proc 
    mov al, level
    mov ah, 0
    mov cx, ax
    xor si, si                   
    display_loop:
    mov al, [sequence + si]
    mov ah, 0Eh                        
    int 10h                      
    inc si
    loop display_loop
    call delay   
    call clear_screen
    ret
        display_sequence endp
   

        
    get_player_input proc 
    lea dx, prompt_msg
    mov ah, 09h           
    int 21h                      
    mov al, level
    mov ah, 0
    mov cx, ax                  
    xor di, di                   
   input_loop:
    mov ah, 00h ; input of player                 
    int 16h                      
    mov [player_input + di], al  
    mov ah, 0Eh                  
    int 10h
    inc di                       
    loop input_loop              
    ret
        get_player_input endp

    check_input proc
    mov al, level
    mov ah, 0
    mov cx, ax           
    xor si, si
    xor di,di
    mov correct, 1               
    compare_loop:
    mov al, [sequence + si]     
    cmp al, [player_input + di] 
    jne incorrect_input          
    inc si
    inc di 
    loop compare_loop
    ret
    incorrect_input:
    mov correct, 0               
    ret
        check_input endp
    
    delay proc
    mov cx, 0000fh  ;The number of iterations for the loop is defined in CX.        
    mov dx, 0      ;CX:DX holds the delay time in microseconds (high word).
                   ;DX is the low word of the delay time
    mov ah, 86h    ;with function 86h to introduce a delay.
    int 15h    
     
    
    delay_loop:
    nop   ;Perform no operation (just consume time).  
    loop delay_loop
    ret
        delay endp
    
    clear_screen proc 
   mov ah, 06h           ; Set AH to 06h to use the scroll function.
   mov al, 0             ; AL = 0 means to clear the entire screen.
   mov bh, 07h           ; Set background attribute to white (or default color).
   mov cx, 0             ; Top-left corner of the screen.
   mov dx, 184Fh         ; Bottom-right corner of the screen (80x25 mode).
   int 10h               ; Call BIOS interrupt 10h for screen operations.
   ret                   ; Return from procedure.

        clear_screen endp
    
    
    
    .exit  
    main endp 
 end main