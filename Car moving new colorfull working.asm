.model small
.stack 64h
.data       
c1 db 03
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
    
              

    
    again:  
                  
 MOV AX,0600h ;AH=06h & AL=00h
    MOV BH,bgcolor ;White background (7)
               ;red foreground(4)
    MOV CX,0000h ;row 0 col 0
    MOV DX,184Fh ;row 24 col 79(inHex)
    INT 10h
    mov ah,02h
    mov dl,20h
    int 21h
    mov ax,0601h
    mov bh,23h
    mov ch,06
    mov cl,c1
    mov dh,07
    inc c1
    mov dl,c1
    int 10h      
    
    
    mov ax,0601h
    mov bh,23h
    mov ch,06
    mov cl,c2
    mov dh,07
    inc c2
    mov dl,c2
    int 10h
    
    
    mov ax,0603h
    mov bh,71h
    mov ch,03
    mov cl,c
    mov dh,06
    mov dl,cc
    int 10h        
     
    
    mov ax,0601h
    mov bh,23h
    mov ch,02
    mov cl,c3
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
    mov dl,c4
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