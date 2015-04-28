; saver.asm Tasm code Demonstrates most aspects of TSR coding 
;
; Com program   Modified 6/13/2002,2007   Andrew Kennedy
;
;  Works up to Win 98 and XP(in a window, NOT FULLSCREEN !!)
;  Screen saver (blanks screen) Activates after 3 minutes  COM file
;
;  Only works in 80x25 screen modes (2,3,7) [could easily be adapted/others]
;        Uses F-8 key to activate, uninstall by typing name of program again
;
;   **** ADJUSTABLE time interval to pop up
;
;                                                                      

;
.SEQ               ; store segment sequentially as they appear
.286               ; use 80286+ code
.MODEL tiny        ; TINY model to make it a .COM program

;* Macros *

StAlloc MACRO sizew    ; macro to allocate stack, size "sizew" words

 MOV BX,((sizew*2)+15) SHR 4    ; BX = size in paragraphs
 MOV AH,48h        ; allocate memory function
 INT 21h           ; call DOS
 CLI               ; freeze interrupts
 MOV SS,AX         ; set stack segment to allocated segment returned in AX
 MOV SP,sizew*2-2  ; set stack pointer to end of segment (goes top down)
 STI               ; restore interrupts

ENDM

StDeAlloc MACRO    ; macro to deallocate stack

 MOV AX,SS
 MOV ES,AX
 MOV AH,49h        ; call DOS deallocate block function
 INT 21h

ENDM

;* Code Segment *

code SEGMENT PARA PUBLIC 'CODE'    ; code segment
ASSUME CS:code, DS:code, ES:code, SS:code  ; assume CS->"code" etc.
ORG 100h                           ; start assembling at offset 0h (default)

;* Program Start *

start:               ; label for start of program
 JMP init

;* Procedures *

; Save screen and display (init) screen saver logo

ScreenSaver PROC NEAR

 MOV AX,CS
 MOV ES,AX
 MOV DI,OFFSET ScrData
 MOV DS,CS:ScrAddress
 XOR SI,SI
 CLD
 MOV CX,2000
 REP MOVSW           ; save screen
 MOV CS:SSOn,1

 MOV AH,0Fh
 INT 10h             ; get current page in BH
 MOV AH,03h
 INT 10h             ; get old cursor size
 MOV CS:OldCursor,CX
 MOV AH,01h
 MOV CX,0100h
 INT 10h             ; hide cursor
 CALL RunSaver       ; clear screen
 CALL DrawSaver      ; draw logo
 RET

ENDP

; Restore screen and deinitialize screen saver

RemoveSaver PROC NEAR

 MOV ES,CS:ScrAddress
 XOR DI,DI
 MOV AX,CS
 MOV DS,AX
 MOV SI,OFFSET ScrData
 CLD
 MOV CX,2000
 REP MOVSW
 MOV CS:SSOn,0
 MOV AH,01h
 MOV CX,CS:OldCursor
 INT 10h           ; restore cursor
 RET

ENDP

; Re-hide screen to cover any writing

RunSaver PROC NEAR   ; this erases the screen

 MOV ES,CS:ScrAddress
 XOR DI,DI
 MOV CX,2000
 xor ax,ax ; XOR AX,AX
 ;mov ax,0720h
 REP STOSW

RET

ENDP

; Find parts of screen that were changed and save to virtual screen

DeltaSaver PROC NEAR

 CLD
 MOV DS,CS:ScrAddress
 XOR SI,SI            ; DS:SI -> physical screen
 MOV AX,CS
 MOV ES,AX            
 MOV DI,OFFSET ScrData  ; ES:DI -> virtual screen
 XOR BH,BH            ; row 0

ds_nextrow:

 MOV CX,80
 CMP BH,CS:Row        
 JZ ds_check          ; if row of copyright string handle separately

ds_loop:

 LODSW
 CMP AX,0             ; check if still zero (as set by screen saver)
 JZ ds_again

 MOV ES:[DI],AX       ; set to new value

ds_again:

 INC DI
 INC DI
 LOOP ds_loop

ds_new:

 INC BH
 CMP BH,25
 JNZ ds_nextrow
 RET

ds_check:

 MOV BP,OFFSET Copyright
 MOV BL,CS:Color

ds_loop2:

 LODSW
 CMP AL,ES:[BP]
 JNZ ds_delta
 CMP AH,BL
 JZ ds_ok

ds_delta:

 MOV ES:[DI],AX

ds_ok:

 INC DI
 INC DI
 INC BP
 LOOP ds_loop2
 JMP SHORT ds_new

ENDP

; Draw copyright string

DrawSaver PROC NEAR

 MOV AX,WORD PTR CS:Row2
 MOV WORD PTR CS:Row,AX  ; now safe to copy incremented data
 MOV AH,CS:Row
 MOV AL,160
 MUL AH
 MOV DI,AX
 MOV AX,CS
 MOV DS,AX
 MOV SI,OFFSET CS:Copyright
 MOV AH,CS:Color

ds_write:

 LODSB
 OR AL,AL
 JZ ds_donemsg
 STOSW
 JMP SHORT ds_write

ds_donemsg:

 RET

ENDP

; move message and change color

IncSaver PROC NEAR

 MOV AX,WORD PTR CS:Row2  ; AL = row, AH = attribute
 ADD AX,101h              ; increment both
 CMP AL,25
 JNZ is_rowset

 XOR AL,AL

is_rowset:

 CMP AH,16
 JNZ is_colset
 MOV AH,1

is_colset:

 MOV WORD PTR CS:Row2,AX
 RET

ENDP

; INT 09h interrupt handler
; checks for hotkey combinations and deinstalls or activates program if found

Int09Handler PROC FAR

 PUSHF
 CALL CS:OldInt09      ; call old handler
 PUSHA
 PUSH DS
 PUSH ES
 MOV AX,40h
 MOV ES,AX
 MOV DI,ES:[1Ah]
 CMP DI,ES:[1Ch]       ; quit if no keys in keyboard buffer
 JZ i9_exit
 MOV CS:SSTimer,0      ; zero timer for screen saver
 CMP CS:SSOn,0
 JZ i9_skip
 CALL RemoveSaver      ; if screen saver active, restore screen

i9_skip:

 MOV DI,ES:[DI]        ; get key in keyboard buffer
 CMP DI,4200h          ; check for F8 , zeroes needed after scan code
 JNZ i9_exit
 PUSH DI
 PUSH ES
 CALL ScreenSaver      ; startup screen saver
 POP ES
 POP DI

i9_remove:

 INC WORD PTR ES:[1Ah]
 INC WORD PTR ES:[1Ah] ; remove key from buffer
 CMP WORD PTR ES:[1Ah],3Eh
 JNZ i9_exit
 MOV WORD PTR ES:[1Ah],1Eh      ; wrap around if required

i9_exit:

 POP ES
 POP DS
 POPA
 IRET

ENDP

; INT 1Ch interrupt handler
; activates screen saver when timeout occurs

Int1CHandler PROC FAR

 PUSHF
 CALL CS:OldInt1C
 PUSHA
 PUSH DS

 PUSH ES
 CMP CS:SSOn,0
 JZ i1c_off
 CALL DeltaSaver      ; store changes to virtual screen
 CALL RunSaver        ; blank screen
 CALL DrawSaver       ; draw message or graphic

i1c_off:

 MOV AL,CS:Timer1
 DEC AL
 MOV CS:Timer1,AL
 JNZ i1c_exit
 MOV AH,18
 MOV AL,CS:Timer2
 DEC AL
 JNZ i1c_not19
 INC AH
 MOV AL,5

i1c_not19:

 MOV CS:Timer2,AL
 MOV CS:Timer1,AH
 CMP CS:SSOn,0
 JZ i1c_count
 CALL IncSaver
 JMP SHORT i1c_exit

i1c_count:

 MOV AX,CS:SSTimer
 INC AX
 MOV CS:SSTimer,AX
 CMP AX,180           ; 3 minutes (min x 60 secs)
 JNZ i1c_exit
 XOR AX,AX
 MOV CS:SSTimer,AX    ; set to zero
 CALL ScreenSaver     ; startup screen saver

i1c_exit:

 POP ES
 POP DS
 POPA
 IRET
ENDP

; TSR data

ScrAddress DW 0
OldCursor  DW 0
OldInt09   DD 0
OldInt1C   DD 0
SSTimer    DW 0
SSOn       DB 0
Timer1     DB 18
Timer2     DB 5
ScrData    DW 2000 DUP (?)
Row        DB 0
Color      DB 1
Row2       DB 0
Color2     DB 1

Copyright  DB 'The wise man in the storm prays to God, not for safety from danger but for         deliverance from fear. Ralph Waldo Emerson',0

Sig        DB 'LuKe'


TSR_end LABEL BYTE

; * Main Program *

init:

 MOV AX,CS
 MOV DS,AX
 MOV ES,AX
 MOV BX,OFFSET code_end
 ADD BX,15
 SHR BX,4
 MOV AH,4AH
 INT 21H                         ; free unneeded memory given to program

 StAlloc 50h                     ; allocate stack (saves memory on disk)

 XOR AX,AX
 MOV ES,AX
 PUSH DS
 MOV DS,ES:[26h]
 CMP WORD PTR DS:Sig,'uL'
 JNZ i_skip
 CMP WORD PTR DS:Sig+2,'eK'
 JNZ i_skip
 MOV AX,WORD PTR DS:OldInt09
 MOV BX,WORD PTR DS:OldInt09+2
 CLI
 MOV ES:[24h],AX
 MOV ES:[26h],BX
 MOV AX,WORD PTR DS:OldInt1C
 MOV BX,WORD PTR DS:OldInt1C+2
 MOV ES:[70h],AX
 MOV ES:[72h],BX
 STI
 MOV AX,DS
 MOV ES,AX
 MOV AH,49h
 INT 21h

 POP DS
 MOV AH,09h
 MOV DX,OFFSET Deinstall
 INT 21h

 StDeAlloc

 MOV AX,4C00h
 INT 21h

i_skip:

 POP DS
 MOV AX,0B800h
 CMP BYTE PTR ES:[0449h],7       ; check if current mode @ 0:449 is 7 (mono)
 JNZ i_gotmode
 MOV AX,0B000h

i_gotmode:

 MOV ScrAddress,AX               ; store screen address
 MOV AX,ES:[24h]
 MOV BX,ES:[26h]
 MOV WORD PTR OldInt09,AX
 MOV WORD PTR OldInt09+2,BX      ; save old interrupt 09h
 MOV AX,OFFSET Int09Handler
 MOV BX,CS
 CLI
 MOV ES:[24h],AX
 MOV ES:[26h],BX
 STI
 MOV AX,ES:[70h]
 MOV BX,ES:[72h]
 MOV WORD PTR OldInt1C,AX

 MOV WORD PTR OldInt1C+2,BX      ; save old interrupt 1Ch
 MOV AX,OFFSET Int1CHandler
 MOV BX,CS
 CLI
 MOV ES:[70h],AX
 MOV ES:[72h],BX
 STI
 MOV AH,49h
 MOV ES,CS:[2Ch]
 INT 21h                         ; deallocate environment block
 MOV AH,09h
 MOV DX,OFFSET Install
 INT 21h                         ; display message

 StDeAlloc                       ; deallocate stack

 MOV DX,OFFSET TSR_end
 ADD DX,15
 SHR DX,4
 MOV AX,3100h
 INT 21h                         ; go TSR, exit with errorlevel 0

;* Data Area *

; main program data

Install     DB 13,10,'Screen Saver now installed. (c) Andrew Kennedy 6/3/2007 - press F8 to '
            DB 'activate and Saver to uninstall.',13,10,10,'$'
Deinstall   DB 13,10,'Screen Saver deinstalled Ok.',13,10,10,'$'

;* End Program *

code_end LABEL BYTE                ; mark end of code segment (end of program)
code ENDS                          ; end code segment "code"
END start                          ; end program, start execution at "start:"