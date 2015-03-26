.model small
.stack 64h
.data       
c1 db 03     ;left most wheel
c2 db 06
c3 db 03
c4 db 06
c db 02
cc db 08 
bgcolor db 33h   
.code      

main proc near
    mov ax,@data
    mov ds,ax
    mov es,ax   
    
   ;                MOV AX,0600h ;AH=06h & AL=00h
;    MOV BH,bgcolor ;White background (7)
;               ;red foreground(4)
;    MOV CX,0000h ;row 0 col 0
;    MOV DX,184Fh ;row 24 col 79(inHex)
;    INT 10h 
;    
;                 q
                  
                  ; mov AH, 0Ch
;                   mov AL ,1;color of pixel
;                  mov CX , 00h;Horizontal position of pixel
;                  mov DX , 20h  ;     Vertical position of pixel
;                   mov BH ,00h  ;      Display page number (graphics modes with more
;                              ;than 1 page)  
;                   int 10h       
;
    
    again:  
                  
 MOV AX,0600h ;AH=06h & AL=00h
    MOV BH,bgcolor ;White background (7)
               ;red foreground(4)
    MOV CX,0000h ;row 0 col 0
    MOV DX,184Fh ;row 24 col 79(inHex)
    INT 10h 
    
    mov ah,02h    ;to display
    mov dl,20h
    int 21h   
    
    
    mov ax,0601h
    mov bh,55h
    ;mov ch,06        ;ch for row
    mov cl,c1     ;col               ;left wheel1
    mov dh,07       ;dh  for 
    inc c1
    mov dl,c1
    int 10h      
    
    
    mov ax,0601h
    mov bh,23h
   ; mov ch,06
    mov cl,c2
    mov dh,07                            ; right wheel2
    inc c2
    mov dl,c2
    int 10h
    
    
    mov ax,0603h                ;al sizeof the box
    mov bh,71h                   ;bh color
   ; mov ch,03                ;
    mov cl,c
    mov dh,06
    mov dl,cc                                ;box middle one
    int 10h        
     
    
    mov ax,0601h
    mov bh,55h
    mov ch,02
    mov cl,c3                               ;left wheel2
    mov dh,03
    inc c3
    mov dl,c3
    int 10h    
    
    
    
    mov ax,0601h
    mov bh,23h
    mov ch,02
    mov cl,c4
    mov dh,03
    inc c4
    mov dl,c4                                           ;right wheel2
    int 10h       
    
    
      
      inc c
      inc cc   
      
      
      
      mov ax,0600h
      mov bh,07h
      mov cx,0000
      mov dx,184fh
      int 10h     
      
      
      ;mov cx,0ffffh
      ;again1:
      ;loop again1  
      
      add bgcolor,05h
      
    jmp again
    
 
   
    
    
    mov ax,4c00h
    int 21h    
    main endp
    end main