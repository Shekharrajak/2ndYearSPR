;Snake Game without Borders
.model small

.data

row db 0FEh dup (?)
col db 0FEh dup (?)

temp_row db ?
temp_col db ?

;variables for food
rand_food_col db ?
rand_food_row db ?

eat_food_col db ?
eat_food_row db ?

delaytime db 1

head db '@' ,'$'
food db 'F' ,'$'

snake_length db 5
snake_loop db ?

color db 0Fh
food_color db 0Fh

cycle db 0
cycletime equ 100
input db ?

.stack 100h
.code
;///////////////////////////////////////////////////////////////////////////////////////
;clear registers:
clear_reg proc
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
clear_reg endp




;//////////////////////////////////////////////////////////////////////////////////////////////
;food functions 
random macro number
mov ah, 00h
    int 1ah

    mov ax,dx
    xor dx,dx
    mov cx,number
    div cx
endm


copy_print_food proc

cmp cycle, 1
jne set_foodpos
random 80
mov rand_food_col, al
random 25
mov rand_food_row,al


set_foodpos:
mov dl, rand_food_row
mov dh, rand_food_col
xor bh,bh
mov ah,02h
int 10h

mov al, food
mov bh, 0
mov bl, food_color  
mov cx, 1
mov ah, 09h
int 10h 

copy_print_food endp


;//////////////////////////////////////////////////////////////////////////////////////////////
lefty proc
    mov dl,col[0]
    cmp dl, 0
    je resetposr

    sn:
    dec dl
    jmp leftyie

    resetposr:
    mov dl, 79


    leftyie:
    mov col[0],dl
    ret 
    lefty endp

righty proc
    mov dl,col[0]
    cmp dl,79
    je resetposl

    zero: 
    inc dl
    jmp rightyie


    resetposl:
    mov dl, 0

    rightyie:
    mov col[0],dl
    ret 
righty endp


upy proc
    mov dh,row[0]
    cmp dh,0
    je resetposd

    upzero:
    dec dh
    jmp uptie

    resetposd:
    mov dh,24


    uptie:
    mov row[0],dh
    ret


upy endp

downy proc
mov dh,row[0]
cmp dh,24
je resetposu

gozero:
inc dh
jmp downty

resetposu:
mov dh, 0

downty:
mov row[0],dh
ret 
downy endp





delay proc
    mov ah, 00
    int 1Ah
    mov bx, dx

jmp_delay:
    int 1Ah
    sub dx, bx
    cmp dl, delaytime
    jl jmp_delay

    inc cycle
    cmp cycle, cycletime
    jne stay

    mov cycle,0

    stay:
    ret
delay endp




clear proc near
    mov al, 03h 
    mov ah, 00h
    int 10h

    mov cx, 3200h  ;stop cursor blinking
    mov ah, 01h
    int 10h
    ret
clear endp
;////////////////////////////////////////////////////////////////////////////////
;this macro will print the whole snake 
complete_print macro r,c,char,color
    mov dh, r
    mov dl, c
    xor bh, bh
    mov ah, 02h
    int 10h 

    mov al, char
    mov bh, 0
    mov bl, color
    mov cx, 1
    mov ah, 09h
    int 10h 
endm

snake proc

    call delay
    call clear


    mov bl,0
    mov bh,0
    print_snake:

    mov dl,[col+bx]
    mov temp_col,dl

    mov dl,[row+bx]
    mov temp_row,dl

    mov snake_loop,bl

    complete_print temp_row,temp_col,head,color
    inc snake_loop
    mov bl, snake_loop
    mov al, snake_loop
    cmp al, snake_length
    ;continue to print the body of the snake
    jl print_snake


    mov bl, snake_length

    ;transfer the coordinates   
    ;to insert new coordinates
    mov bh,0
    transfer:
    dec bx
    mov dl ,[col+bx]
    mov [col + bx + 1],dl

    mov dl,[row + bx]
    mov [row+bx+1],dl
    cmp bx,0
    jg transfer

ret
snake endp





main proc
;//////////////////////////////////////////////////////////////////////
      mov ax, @data
    mov ds, ax
    call clear
    ;initialize starting body snake :)
    mov row[0],12
    mov row[1],12
    mov row[2],12
    mov row[3],12
    mov row[4],12

    mov col[0],40
    mov col[1],39
    mov col[2],38
    mov col[3],37
    mov col[4],36
    print:  
    call snake

;//////////////////////////////////////////////////////////////////////
; moving the snake
    ;initialize the keyboard input:
    comment @
    mov ah,00h
    int 16h
    mov input, 'd'

    ;to change direction or to keep going


    ; wait for keystroke
    ; if no key is pressed, value of input will be 
    ;last key pressed.
        mov ah, 01h
        int 16h
        jz key
    @
    getinput:
    ;key is pressed, new value of input
        mov ah,00h
        int 16h
        mov input, al

    key: 
    ;UP
    cmp input, 'w'
    je w 
    ;DOWN
    cmp input, 's'
    je s
    ;LEFT
    cmp input, 'a'
    je a 
    ;RIGHT
    cmp input, 'd'
    je d

    jne getinput

    ;make the snake go up
    w:
    call upy
    jmp rak

    ;make the snake go up
    s:
    call downy
    jmp rak

    ;make the snake go left
    a:
    call lefty
    jmp rak

    ;make the snake go right
    d:
    call righty
    jmp rak



    rak:

    ;call copy_print_food



    call snake  


    jmp getinput



    mov ax, 4c00h
    int 21h

main endp
end main