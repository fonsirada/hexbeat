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

macro copy16bit
    push hl

    ld a, high(\3)
    ld \1, a
    ld a, low(\3)
    ld \2, a

    pop hl
endm

macro SetRegBit
    push af

    ld a, [\1]
    set \2, a
    ld [\1], a

    pop af
endm

macro ResRegBit
    push af

    ld a, [\1]
    res \2, a
    ld [\1], a
    
    pop af
endm

macro RegBitOp
    ld a, [\1]
    \3 \2, a
    ld [\1], a
endm

; THIS WORKS???
macro RegOp
    ld a, [\1]
    \2 a
    ld [\1], a
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LCD control / Graphics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; load the graphics data from ROM to VRAM
macro LoadGraphicsDataIntoVRAM
    ld de, GRAPHICS_DATA_ADDRESS_START
    ld hl, _VRAM8000
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, d
        cp a, high(GRAPHICS_DATA_ADDRESS_END)
        jr nz, .load_tile\@
endm

; clear the OAM
macro InitOAM
    ld c, OAM_COUNT
    ld hl, _OAMRAM + OAMA_Y
    ld de, sizeof_OAM_ATTRS
    .init_oam\@
        ld [hl], 0
        add hl, de
        dec c
        jr nz, .init_oam\@
endm

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

; sets 0th bit in rGAME register - so program knows the game has started (level screen)
macro StartGame
    ld a, [rGAME]
    set 0, a
    ld [rGAME], a
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


;;;;;

endc