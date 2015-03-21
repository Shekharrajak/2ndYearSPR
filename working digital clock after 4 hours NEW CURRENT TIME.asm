.model small
.stack 
.data 
    h db 00h
    m db 00h
    s db 00h
    sixty db 3ch 
     RES  DB 10 DUP ('$')     
   
.code 


setcurser macro col
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,col
    int 10h
endm 

PRINT MACRO M 
    
    MOV AH,02H
    MOV DL,M
    INT 21H
ENDM


;   print macro h 
 ;    mov ah,00h
  ;   mov al,h
   ;   ;mov cl,10
    ;  ;mov bl,al
     ; ;mov bh,ah
      ;
     ; cmp al,9h
      ;
     ; MOV AH,2
     ; MOV DL,BH
     ; add dl,30h
     ; INT 21H
     ;
     ; MOV AH,2 
     ; 
     ; MOV DL,BL 
     ; add dl,30h
     ; INT 21H
   ; endm
         


    
    mov ax,@data
    mov ds,ax  
    
    
    
    MOV AH,2CH
    INT 21H 
    MOV H,CH
    MOV M,CL
    MOV S,DH
    
 
    
    
    
    ;dec sixty
    
    MOV AX,0600h ;AH=06h & AL=00h
    MOV BH,61h ;White background (7)
               ;red foreground(4)
    MOV CX,0000h ;row 0 col 0
    MOV DX,184Fh ;row 24 col 79(inHex)
    INT 10h
    
    ;mov ah,02h
    ;mov dh,0ah
    ;mov dl,23h
    ;int 10h 
        ;   
        
        ;FOR CURRECNT TIME
        
;         MOV AH,2CH
;    INT 21H
;    
;     LEA SI,RES
;    CALL HEX2DEC
;   
;    LEA DX,RES
;    MOV AH,9
;    INT 21H
;    
;    PRINT ':'
;    
;     LEA SI,RES
;    CALL HEX2DEC
;   
;    LEA DX,RES
;    MOV AH,9
;    INT 21H
;     
;      PRINT ':'
;     LEA SI,RES
;    CALL HEX2DEC
;   
;    LEA DX,RES
;    MOV AH,9
;    INT 21H
;       
;      PRINT ':'
;     LEA SI,RES
;    CALL HEX2DEC
;   
;    LEA DX,RES
;    MOV AH,9
;    INT 21H
;       
;      PRINT ':'
;        PRINT ':'
;          PRINT ':'
;    
;    
;   
    hh: 
    setcurser 00h
    mov bh,00h  
        mov bl,h
      MOV AX,bx
      
    LEA SI,RES
    CALL HEX2DEC
   
    LEA DX,RES
    MOV AH,9
    INT 21H
        
    mov ah,02h
    mov dl,':'
    int 21h 
    
    
    mm:  
     setcurser 03h
    mov bh,00h  
        mov bl,m
      MOV AX,bx
    LEA SI,RES
    CALL HEX2DEC
   
    LEA DX,RES
    MOV AH,9
    INT 21H
        
    mov ah,02h
    mov dl,':'
    int 21h 
             
             
    ss1:  
        setcurser 06h
       
         mov bh,00h  
        mov bl,s
      MOV AX,bx
      
    LEA SI,RES
    CALL HEX2DEC
   
    LEA DX,RES
    MOV AH,9
    INT 21H
    
    CALL DELAY
    
        inc s  
        mov bl,sixty
        cmp s,bl
        jb ss1
        ;jmp minc
        ;mov bl,00h
        setcurser 03h
        inc m 
        ;mov m,00h
        mov s,00h 
        cmp m,bl
        je minc
        jmp mm
    
      ;end ss
        
     minc :
        ;inc m
        ;mov bl,sixty     
        ; mov s,00h
        ;cmp m,bl
        ;jb mm
        inc h
        jmp hh
         
        ;mov bl,03h
       
        ;jmp mm
        
HEX2DEC PROC NEAR
    MOV CX,0
    MOV BX,10
   
LOOP1: MOV DX,0
       DIV BX
       ADD DL,30H
       PUSH DX
       INC CX
       CMP AX,9
       JG LOOP1
     
       ADD AL,30H
       MOV [SI],AL
     
LOOP2: POP AX
       INC SI
       MOV [SI],AL
       LOOP LOOP2
       RET
HEX2DEC ENDP  

DELAY PROC NEAR
    MOV CX,111100B
    COUNT:
          DEC CX
          LOOP COUNT
RET


      
    mov ah,4ch
    int 21h
    end