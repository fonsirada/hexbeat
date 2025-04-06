;
; CS-240 World 5: Basic Game Functionality
;
; @file main.asm
; @author Darren Strash
; @date March 4, 2025
;
; build with:
; make

include "src/hardware.inc"
include "src/joypad.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "header", rom0[$0100]
entrypoint:
    di
    jp main
    ds ($0150 - @), 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

section "main", rom0
main:
    DisableLCD
    call InitGraphics
    call InitSpriteData
    call InitPlayer
    call InitSprites

    InitJoypad
    EnableLCD

    .loop ; not enough time in vblank rn...
        call Start
        
        ld a, [rGAME]
        bit 0, a ; check if game is started; replace w/ consts or macros
        jr z, .post_graphics
            call UpdateGraphics
            call UpdatePlayer
            call UpdateSprites
        .post_graphics
        UpdateJoypad
        jr .loop
