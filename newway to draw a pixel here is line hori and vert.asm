
jmp start

;  Draws a horiz and vert line
;==============================
  startaddr	dw	0a000h	;start of video memory
  colour	db	1

 start:
   mov ah,00
   mov al,19
   int 10h			;switch to 320x200 mode

 horiz:
   mov es, startaddr		;put segment address in es
   mov di, 32000		;row 101 (320 * 100)
   add di, 75			;column 76
   mov al,colour		;cannot do mem-mem copy so use reg
   mov cx, 160			;loop counter
   
  hplot:
    mov es:[di],al		;set pixel to colour
    inc di			;move to next pixel
  loop hplot
 vert:
   mov di, 16000		;row 51 (320 * 50)
   add di, 160			;column 161
   mov cx, 100			;loop counter
  vplot:
    mov es:[di],al
    add di, 320			;mov down a pixel
  loop vplot

 keypress:
   mov ah,00
   int 16h			;await keypress
 end:
  ; mov ah,00
;   mov al,03
   int 10h
   mov ah,4ch
   mov al,00			;terminate program
   int 21h
