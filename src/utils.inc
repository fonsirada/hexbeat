; 
; HEXBEAT (CS-240 World 8)
;
; @file utils.inc
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 24, 2025
; @license GNU GPL v3
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
macro Copy16BitVal
    ld a, high(\3)
    ld \1, a
    ld a, low(\3)
    ld \2, a
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

; compare the current value of a given timer register
macro CheckTimer
    ld a, [\1]
    cp \2
endm

; increment (or reset) a given timer
macro IncTimer
    ld a, [\1]
    cp a, \2
    jr nz, .finish_update\@
        xor a
    .finish_update\@
    inc a
    ld [\1], a
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc