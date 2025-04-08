; 
; CS-240 World 5: Basic Game Functionality
;
; @file joypad.inc
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 7, 2025
; @brief stores joypad handling macros

if !def(JOYPAD_RGBINC)
def JOYPAD_RGBINC equ 1

include "src/wram.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def NONE_HELD       equ $FF
def HIGH_NIB_MASK   equ $F0
def LOW_NIB_MASK    equ $0F

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; initialize stored joypad buttons to so that
; none of them are initially detected as held
macro InitJoypad
    ld a, NONE_HELD
    ld [PAD_CURR], a
    ld [PAD_PREV], a
    ld [PAD_RLSE], a
    ld [PAD_PRSS], a
endm

; read the keypad input into a pad input struct
; expected to be used only once in the main loop
macro UpdateJoypad
    ; store the previous input into the struct and (c)
    ld a, [PAD_CURR]
    ld [PAD_PREV], a
    ld c, a

    ; read the dpad
    ld a, P1F_GET_DPAD
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]

    ; put the dpad input into (b)'s high nibble
    swap a
    and a, HIGH_NIB_MASK
    ld b, a

    ; read the buttons
    ld a, P1F_GET_BTN
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]

    ; merge the buttons' input into (b)'s low nibble
    and a, LOW_NIB_MASK
    or a, b
    ld b, a

    ; store the current input
    ld [PAD_CURR], a

    ; disable input polling
    ld a, P1F_GET_NONE
    ldh [rP1], a

    ; compute and store pressed buttons
    ld a, c
    cpl
    or a, b
    ld [PAD_PRSS], a

    ; compute and store released buttons
    ld a, b
    cpl
    or a, c
    ld [PAD_RLSE], a
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc