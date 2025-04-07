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
include "src/utils.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "header", rom0[$0100]
entrypoint:
    di
    jp main
    ds ($0150 - @), 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "main", rom0
main:
    DisableLCD

    call InitGraphics
    call InitSpriteData
    call InitPlayer
    call InitSprites
    InitJoypad
    EnableLCD

    .loop
        call Start

        ld a, [rGAME]
        bit GAMEB_STARTED, a ; check if game is started; replace w/ consts or macros
        jr z, .post_graphics
            call UpdateGraphics
            call UpdatePlayer
            call UpdateSprites
        .post_graphics

        UpdateJoypad

        jr .loop
