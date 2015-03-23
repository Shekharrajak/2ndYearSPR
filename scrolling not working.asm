;Shows a demonstration of a routine which scrolls a window on a text mode screen
;
;%SUBTTL "Scroll Window Left routine with sample driver"
;
; Scroll2.Asm
;
; see ScrollLeft description for complete explanation of this program
;
       .MODEL   small
;        .IDEAL
        .STACK   200h        ; this is more than enough stack
;        CODESEG
start:
;
; this test stub scrolls the window at (4,3)-(22,68) left 9 columns,
; filling in with spaces of attribute white on black (07)
;
        mov     al,9        ; number of columns to scroll
        mov     bh,07       ; attribute to use for blanked chars
        mov     ch,4        ; row of upper left hand corner of window
        mov     cl,3        ; col of upper left hand corner of window
        mov     dh,22       ; row of lower right hand corner of window
        mov     dl,68       ; col of lower right hand corner of window

        call    ScrollLeft

        mov     ah,4ch      ; exit with errorlevel from scroll routine
        int     21h
;
; ScrollLeft
;
; PURPOSE:  scrolls a rectangular region of a text screen (window) to the
;           left by a variable number of columns
;
;
; INPUTS:   AL = number of columns to scroll (if zero, no effect)
;           BH = attribute to use for blanked characters
;        CH,CL = row, col for upper left hand corner of window
;        DH,DL = row, col for lower right hand corner of window
;
; NOTES: upper left hand corner of screen (home) is (0,0)
;        video adapter is checked to see if it's in text mode
;        screen dimensions are taken from BIOS data
;        calling sequence is nearly identical to BIOS scroll routine
;        display pages supported
;        dual monitors supported
;        MDA/CGA/EGA/VGA supported
;
; RETURNS:  On error, Carry flag set, AX contains error number
;           otherwise carry is clear, AX contains 0
;
;     Error codes:  0   -   no error
;                  -1   -   some error occurred
;
PROC    ScrollLeft
        ScrRows   equ   0484h     ; location of BIOS rows data
        ScrCols   equ   044ah     ; location of BIOS cols data
        ScrMode   equ   0449h     ; location of BIOS mode data
        ScrOffs   equ   044eh     ; location of BIOS scrn offset data

;       first, save all of the registers we're going to trash
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    bp
        push    es
        push    ds

        mov     bl,al         ; stow cols in BL
        xor     ax,ax
        mov     ds,ax         ; point data seg to 0000 to read BIOS data
        cmp     ch,dh         ; srow > erow ?
        ja      @@badcoords
        cmp     cl,dl         ; scol > ecol ?
        ja      @@badcoords
;
;  now we need to load ScrRows, if we haven't got EGA or better
;
        mov     al,[ScrRows]  ; is MAXROWS = 0 ?
        cmp     al,0          ; if so, then assume we've got MDA or CGA
        jne     @@ega_plus    ; if not, we've got correct value already
        mov     al,24         ; otherwise, assume 25 rows (and load 25-1)
@@ega_plus:
        cmp     dh,al         ; erow >= MAXROWS?
;
;  note that BIOS actually stores MAXROWS-1 in this location, so the
;  actual jump instruction is (correctly) written as ja
;
        ja      @@badcoords
        cmp     dl,[ScrCols]  ; ecol >= MAXCOLS?
        jae     @@badcoords
        mov     ah,bl         ; remember cols
        add     ah,cl         ; cols + scol
        cmp     ah,dl         ; (cols + scol) > ecol ?
        ja      @@badcoords

; figure out where the video buffer starts
        mov     bp,0b800h     ; first guess
        mov     al,[ScrMode]  ; get mode from BIOS' RAM
        cmp     al,4          ; if mode is 0 through 3, we're all set
        jb      @@modeOK
        mov     bp,0b000h     ; second guess
        cmp     al,7          ; is it mode 7 (monochrome 80 col) ?
        je      @@modeOK      ; if so, we're still OK
@@badcoords:
        mov     ax,-1         ; set error code
        stc                   ; and set error (carry) flag
        jmp     @@exit
@@modeOK:
        mov     es,bp         ; set up our video pointer segment

; ES:DI = endloc  = Screen + 2 * (MAXCOLS * srow + scol)

        mov     di,[ScrOffs]  ; offset of screen buffer
        xor     ah,ah         ; clear out high half of AX
        mov     al,[ScrCols]  ; get the width of the screen
        mul     ch            ; multiply width by the row number
        add     al,cl         ; now add the column number
        adc     ah,0          ; propagate carry bit to other half of AX
        shl     ax,1          ; now multiply by 2 bytes/char
        add     di,ax         ; add the offset to the screen start address

; DS:DI = startloc = endloc + 2 * cols

        xor     ah,ah         ; clear top half of ax
        mov     al,bl         ; recall cols
        mov     si,di         ; start address = end address
        add     si,ax         ; add cols
        add     si,ax         ; and again

; start on count calculation (figure ecol-scol+1)
        sub     dl,cl         ; ecol - scol
        inc     dl            ; now dl = ecol - scol + 1
  
; calculate increment and stow in BP
;   increment = (MAXCOLS - (ecol - scol + 1)) * 2
        xor     ah,ah         ; clear top half of ax
        mov     al,dl         ; use partial count calculation
        neg     ax
        add     al,[ScrCols]  ; now add in screen width
        adc     ah,0          ; propagate carry bit to hi half of AX
        shl     ax,1          ; now double it (2 bytes/char)
        mov     bp,ax

; finish count calculations and put in DL
;   count = (ecol - scol + 1) - cols

        sub     dl,bl         ; figure in cols

        mov     ax,es         ; recall our video pointer
        mov     ds,ax         ; now duplicate it

; load up AX with char and attribute for blank space
        mov     al,32         ; ASCII space character
        mov     ah,bh         ; passed attribute byte

        sub     dh,ch         ; get row count
        mov     dh,bh         ; save loop count (rows to move) in bh
        xor     ch,ch         ; zero out hi half of CX
        cld                   ; assure that we move the right direction (up)
@@looptop:
        mov     cl,dl         ; load in count (words to move)
        rep     movsw         ; move the line over
        mov     cl,bl         ; recall cols   (blanks to insert)
        rep     stosw         ; fill in the rest of the line
        add     di,bp         ; advance to next line by adding increment
        mov     si,di         ; now set up the other (source) pointer
        mov     cl,bl         ; recall cols
        add     si,cx         ; add in cols
        add     si,cx         ; and again (because 2 bytes/char)
        dec     bh            ; decrement loop counter
        ja      @@looptop     ; skip back if we're not done yet
        mov     ax,0          ; set error code to zero (all OK)
        clc                   ; and clear error (carry) flag
@@exit:
        pop     ds            ; restore all of our registers
        pop     es
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        ret                   ; mosey on home again

ENDP    ScrollLeft
        END     start
-+------- cut here -----------
