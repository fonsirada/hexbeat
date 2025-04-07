; 
; CS 240: Storing Joypad state, including pressed/released/etc
;
; @file wram.inc
; @author Darren Strash and CS 240
; @brief a place to store all WRAM variables

if !def(JOYPAD_RGBINC)
def JOYPAD_RGBINC equ 1

include "src/wram.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def NONE_HELD equ $FF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; init a pad input struct at address \1
; expected to be used only once at initialization
; example: InitPadInput _RAM + 16
macro InitPadInput
    ld a, $FF
    ld [\1 + PAD_INPUT_CURRENT], a
    ld [\1 + PAD_INPUT_PREVIOUS], a
    ld [\1 + PAD_INPUT_PRESSED], a
    ld [\1 + PAD_INPUT_RELEASED], a
endm

; read the keypad input into a pad input struct at address \1
; expected to be used only once in the main loop
; example: UpdatePadInput _HRAM + 4
macro UpdatePadInput
    ; store the previous input into the struct and (c)
    ld a, [\1 + PAD_INPUT_CURRENT]
    ld [\1 + PAD_INPUT_PREVIOUS], a
    ld c, a

    ; read the dpad
    ld a, P1F_GET_DPAD
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]

    ; put the dpad input into (b)'s high nibble
    swap a
    and a, $F0
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
    and a, $0F
    or a, b
    ld b, a

    ; store the current input
    ld [\1 + PAD_INPUT_CURRENT], a

    ; disable input polling
    ld a, P1F_GET_NONE
    ldh [rP1], a

    ; compute and store pressed buttons
    ld a, c
    cpl
    or a, b
    ld [\1 + PAD_INPUT_PRESSED], a

    ; compute and store released buttons
    ld a, b
    cpl
    or a, c
    ld [\1 + PAD_INPUT_RELEASED], a
endm

; initialize stored joypad buttons to so that
; none of them are initially detected as held
macro InitJoypad
    ld a, NONE_HELD
    ld [PAD_CURR], a
    ld [PAD_PREV], a
    ld [PAD_RLSE], a
    ld [PAD_PRSS], a
endm

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
    and a, $F0
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
    and a, $0F
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

endc