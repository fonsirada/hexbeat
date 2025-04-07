; 
; CS-240 World 5: Basic Game Functionality
;
; @file utils.inc
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @brief store general usage macros

if !def(UTILS_RGBINC)
def UTILS_RGBINC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "src/hardware.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; copy \2 into \1 through (a)
; example: copy [$FF84], 10
macro copy
    push af

    ld a, \2
    ld \1, a

    pop af
endm

; copy 16bit reg \2 into 16bit reg \1 using (a)
macro copy16bit
    push hl

    ld a, high(\3)
    ld \1, a
    ld a, low(\3)
    ld \2, a

    pop hl
endm

; run a bit operation \3 on address \1 at bit \2 using (a)
macro RegBitOp
    ld a, [\1]
    \3 \2, a
    ld [\1], a
endm

; run an operation \2 on address \1 using (a)
macro RegOp
    ld a, [\1]
    \2 a
    ld [\1], a
endm


;;; LCD CONTROL

macro DisableLCD
    ; wait for the vblank
    .wait_vblank\@
        ld a, [rLY]
        cp a, SCRN_Y
        jr nz, .wait_vblank\@

    ; turn the LCD off
    xor a
    ld [rLCDC], a
endm

macro EnableLCD
    ; set the graphics parameters and turn back LCD on
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [rLCDC], a

endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc