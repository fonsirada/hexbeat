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

macro copy16bit
    push hl
    ld hl, \1
    ld \2, hl
    /*
    ld h, high(\2)
    ld l, low(\2)
    ld high(\1), h
    ld low(\1), l
    */
    pop hl
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pad input
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





; raise the zero flag if all keys in \2 are held in the pad input struct \1
; example: TestPadInput_HeldAll _RAM + 4, PADF_LEFT | PADF_DOWN
macro TestPadInput_HeldAll
    ld a, [\1 + PAD_INPUT_CURRENT]
    and a, \2
endm

; raise the zero flag if input \2 is pressed in the pad input struct \1
; example: TestPadInput_Pressed _HRAM + 12, PADF_LEFT
macro TestPadInput_Pressed
    ld a, [\1 + PAD_INPUT_PRESSED]
    and a, \2
endm

; raise the zero flag if input \2 is released in the pad input struct \1
; example: TestPadInput_Released _RAM + 24, PADF_A
macro TestPadInput_Released
    ld a, [\1 + PAD_INPUT_RELEASED]
    and a, \2
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc