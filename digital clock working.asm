.model small
.stack 
.data 
    h db 00h
    m db 00h
    s db 00h
    sixty db 50h      
   
.code 


setcurser macro col
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,col
    int 10h
endm  


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
    
    dec sixty
    
    MOV AX,0600h ;AH=06h & AL=00h
    MOV BH,74h ;White background (7)
               ;red foreground(4)
    MOV CX,0000h ;row 0 col 0
    MOV DX,184Fh ;row 24 col 79(inHex)
    INT 10h
    
    ;mov ah,02h
    ;mov dh,0ah
    ;mov dl,23h
    ;int 10h 
    
     
   
    hh:
        ;mov bx,h
        ;print h
         
        mov bl,h
        call displaynum
        ;add bl,30h
        ;mov dl,bl
        ;mov ah,09h
        ;int 10h
        
        ;end hh
        
    mov ah,02h
    mov dl,':'
    int 21h 
    
    
    mm:  
         ;mov bx,m
       mov bl, m
       call displaynum 
        ;add bl,30h
        ;mov dl,bl
        ;mov ah,09h
        ;int 10h 
    
      ;end mm
        
    mov ah,02h
    mov dl,':'
    int 21h 
             
             
    ss1:  
        setcurser 06h
        ;mov bx,s
        mov bl,s
        call displaynum
        
        ;add bl,30h
        ;mov dl,bl
        ;mov ah,09h
        ;int 10h 
        
        inc s  
        mov bl,sixty
        cmp s,bl
        jb ss1
        cmp m,bl
        jb minc
        mov bl,00h
        setcurser bl
        inc h 
        mov m,00h
        jmp hh
    
      ;end ss
        
     minc :
        inc m
        mov s,00h  
        ;mov bl,03h
        setcurser 03h
        jmp mm
        
displaynum proc near


        mov al,bl
        mov cl,04
        and al,0f0h
        shr al,cl
        cmp al,09
        jbe number
        add al,07

number: add al,30h
        mov dl,al
        mov ah,02
        int 21h

        mov al,bl
        and al,00fh
        cmp al,09
        jbe number2
        add al,07
        
number2: add al,30h
         mov  dl,al
         mov ah,02
         int 21h


ret                          ;return from procedure 
displaynum endp   


      
    mov ah,4ch
    int 21h
    end