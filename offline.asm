                                     .MODEL SMALL 
.STACK 100H 
.DATA

N DW ?
CR EQU 0DH
LF EQU 0AH  

MAX_SIZE DW ?
ARRAY DW MAX_SIZE DUP (?)     
I DW  ?
J DW  ?  
TO_FIND DW ?  

NOT_FOUND DB CR, LF, 'NOT FOUND! $' 
FOUND_MSG DB CR , LF , 'FOUND!' , CR , LF , '$'      


.CODE 


TAKE_INPUT PROC
    ; fast BX = 0
  
    PUSH BP
	MOV BP, SP
    PUSH AX
    PUSH BX
    PUSH CX
  
    
    XOR BX, BX
    
    INPUT_LOOP:
    ; char input 
    MOV AH, 1
    INT 21H
    
    ; if \n\r, stop taking input
    CMP AL, CR    
    JE END_INPUT_LOOP
    CMP AL, LF
    JE END_INPUT_LOOP
    
    ; fast char to digit
    ; also clears AH
    AND AX, 000FH
    
    ; save AX 
    MOV CX, AX
    
    ; BX = BX * 10 + AX
    MOV AX, 10
    MUL BX
    ADD AX, CX
    MOV DX , AX
    JMP INPUT_LOOP
    
    END_INPUT_LOOP: 
    
    
     POP CX 
     POP BX
     POP AX  
     POP BP
       
    RET 0
    
    
TAKE_INPUT ENDP

 
 
 
 


PRINT_ARRAY PROC 
    PUSH BP
	MOV BP, SP
    PUSH AX
    PUSH BX
    PUSH CX
     
    MOV BX, OFFSET ARRAY; 
    MOV SI,0 ;
    MOV CX , MAX_SIZE ;
    PRINT_ARRAY_LOOP: 
    MOV AX ,ARRAY[SI] 
    PUSH AX
    CALL PRINT_DECIMAL_INTEGER
    ADD BX , 2        
    ADD SI , 2
    LOOP PRINT_ARRAY_LOOP ; 
    
    POP CX 
    POP BX
    POP AX 
    POP BP
    RET 
PRINT_ARRAY ENDP
    



 
INSERTION_SORT PROC    
     PUSH BP
	 MOV BP, SP
     PUSH AX
     PUSH BX
     PUSH CX
     ; for (int i = 1; i < n ; ++) ;    
     MOV CX ,MAX_SIZE; 
     SUB CX , 1; 
     MOV BX, OFFSET ARRAY 
     MOV SI, 2
     
     
     
     FOR_LOOP:
     MOV DX , ARRAY[SI] ; TEMP = ARRAU[i];   
     MOV DI , SI ; j = i - 1; 
     SUB DI , 2  
     

     
     WHILE_LOOP:
     
     CMP DX, ARRAY[DI] ;  TEMP < ARRAY[j] ; 
     JGE EXIT_WHILE  
     MOV AX,ARRAY[DI] 
     MOV ARRAY[DI + 2], AX
     SUB DI, 2 ; --j 
     CMP DI ,0 ; 
     JGE WHILE_LOOP
     
     EXIT_WHILE:
     
     MOV ARRAY[DI + 2], DX ; ARRAY[J+1] = TEMP;
     ADD SI , 2
     LOOP FOR_LOOP ; 
                  
     POP CX
     POP BX
     POP AX
     POP BP
     RET  0
       
     
INSERTION_SORT ENDP 









BINARY_SEARCH PROC 
   PUSH BP
  MOV BP, SP
  PUSH AX ;
  PUSH BX ; 
  PUSH CX ;
   
  XOR AX, AX ; L = 0  ;
  MOV CX, MAX_SIZE; R = N; 
  
  WHILE_LOOP_:
  CMP AX, CX     ; while(l <r ) ;
  JGE END_WHILE
  MOV SI , AX ; MID = L
  ADD SI , CX ; MID = L + R;  
  ;SHR SI, 1;                     ; mid /= 2; 
  MOV BX , ARRAY[SI]
  
  CMP TO_FIND, BX ;
  JE EQUAL
  JG GREATER 
  JL LESS
  GREATER : 
     MOV AX , SI ; L = MID * 2       
     SHR AX,1 ;   L = MID 
     INC AX ;  L = MID + 1 ;
     JMP WHILE_LOOP_             
  LESS :
     MOV CX, SI ; 
    SHR CX , 1;
     JMP WHILE_LOOP_ 
  EQUAL:
     MOV DX , SI ; 
     SHR DX, 1; 
     JMP FOUND
  
  END_WHILE: 
   
   LEA DX , NOT_FOUND ;
   MOV AH , 9; 
   INT 21H ;
   JMP END_BINARY_SEARCH;
  
  
  FOUND: 
  
    PUSH DX ;
    CALL PRINT_DECIMAL_INTEGER 
    
    LEA DX, FOUND_MSG ;
    MOV AH, 9;
    INT 21H; 
     
  END_BINARY_SEARCH:
    POP CX ; 
    POP BX ;
    POP AX ; 
    POP BP
    RET 
  
  
     
  
  

BINARY_SEARCH ENDP
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  

MAIN PROC 
    MOV AX, @DATA
    MOV DS, AX 
    
    
    CALL TAKE_INPUT ; 
    MOV MAX_SIZE, DX;  
    
    CMP DX ,0 ;
    JE END_PROGRAM 
    CALL PRINT_NEWLINE
    
    
    ;;take input of array   
    
    MOV SI, OFFSET ARRAY ; POINTS TO THE BEGINING OF THE ARRAY
    MOV CX , MAX_SIZE ;
    ARR_IN_LOOP:
    CALL TAKE_INPUT ; INPUT NUMBER IS STORED IN BX ; 
    CALL PRINT_NEWLINE
    MOV [SI] , DX ; STORED IN ARRAY[BX/2] 
    ADD SI, 2 ;  
    LOOP ARR_IN_LOOP   
    
    
    
    
  
    CALL INSERTION_SORT ;   
    
    
     
    CALL PRINT_NEWLINE
    
    
    CALL PRINT_ARRAY
    
    
    
    CALL PRINT_NEWLINE ;   
    
    
    CALL TAKE_INPUT;  
    
    CALL PRINT_NEWLINE
    
    MOV TO_FIND , DX ;
    CALL BINARY_SEARCH
     
     
     
    
   
    
    ;------------------------------------
    ; start from here
    ; input is in N
    
    
    
    
    
      
    END_PROGRAM:
	; interrupt to exit
    MOV AH, 4CH
    INT 21H
    
  
MAIN ENDP  



PRINT_NEWLINE PROC
        ; PRINTS A NEW LINE WITH CARRIAGE RETURN
        PUSH AX
        PUSH DX
        MOV AH, 2
        MOV DL, 0Dh
        INT 21h
        MOV DL, 0Ah
        INT 21h
        POP DX
        POP AX
        RET
    PRINT_NEWLINE ENDP
    
    PRINT_CHAR PROC
        ; PRINTS A 8 bit CHAR 
        ; INPUT : GETS A CHAR VIA STACK 
        ; OUTPUT : NONE    
        PUSH BP
        MOV BP, SP
        
        ; STORING THE GPRS
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSHF
        
        
        
        MOV DX, [BP + 4]
        MOV AH, 2
        INT 21H
        
        
        
        POPF  
        
        POP DX
        POP CX
        POP BX
        POP AX
        
        POP BP
        RET 2
    PRINT_CHAR ENDP 

    PRINT_DECIMAL_INTEGER PROC NEAR
        ; PRINTS SIGNED INTEGER NUMBER WHICH IS IN HEX FORM IN ONE OF THE REGISTER
        ; INPUT : CONTAINS THE NUMBER  (SIGNED 16BIT) IN STACK
        ; OUTPUT : 
        
        ; STORING THE REGISTERS
        PUSH BP
        MOV BP, SP
        
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSHF
        
        MOV AX, [BP+4]
        ; CHECK IF THE NUMBER IS NEGATIVE
        OR AX, AX
        JNS @POSITIVE_NUMBER
        ; PUSHING THE NUMBER INTO STACK BECAUSE A OUTPUT IS WILL BE GIVEN
        PUSH AX

        MOV AH, 2
        MOV DL, 2Dh
        INT 21h

        ; NOW IT'S TIME TO GO BACK TO OUR MAIN NUMBER
        POP AX

        ; AX IS IN 2'S COMPLEMENT FORM
        NEG AX

        @POSITIVE_NUMBER:
            ; NOW PRINTING RELATED WORK GOES HERE

            XOR CX, CX      ; CX IS OUR COUNTER INITIALIZED TO ZERO
            MOV BX, 0Ah
            @WHILE_PRINT:
                
                ; WEIRD DIV PROPERTY DX:AX / BX = VAGFOL(AX) VAGSESH(DX)
                XOR DX, DX
                ; AX IS GUARRANTEED TO BE A POSITIVE NUMBER SO DIV AND IDIV IS SAME
                DIV BX                     
                ; NOW AX CONTAINS NUM/10 
                ; AND DX CONTAINS NUM%10
                ; WE SHOULD PRINT DX IN REVERSE ORDER
                PUSH DX
                ; INCREMENTING COUNTER 
                INC CX

                ; CHECK IF THE NUM IS 0
                OR AX, AX
                JZ @BREAK_WHILE_PRINT; HERE CX IS ALWAYS > 0

                ; GO AGAIN BACK TO LOOP
                JMP @WHILE_PRINT

            @BREAK_WHILE_PRINT:

            ;MOV AH, 2
            ;MOV DL, CL 
            ;OR DL, 30H
            ;INT 21H
            @LOOP_PRINT:
                POP DX
                OR DX, 30h
                MOV AH, 2
                INT 21h

                LOOP @LOOP_PRINT

        CALL PRINT_NEWLINE
        ; RESTORE THE REGISTERS
        POPF
        POP DX
        POP CX
        POP BX
        POP AX
        
        POP BP
        
        RET 2


    PRINT_DECIMAL_INTEGER ENDP


END MAIN 
