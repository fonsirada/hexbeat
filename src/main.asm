;
; CS-240 World 5: Basic Game Functionality
;
; @file main.asm
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 7, 2025
; @brief control overall program loop
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

    call init_graphics
    call init_sprite_data
    call init_player
    call init_sprites
    InitJoypad

    EnableLCD

    .loop
        call start

        ld a, [rGAME]
        bit GAMEB_END, a
        jr z, .check_start
            call game_over
            jr .loop
            ; jr [nz?], .loop
            ; ^ above should restart game on pressing enter
            ; check placement of this

        .check_start
        bit GAMEB_START, a
        jr z, .post_graphics
            ; if things break: out of vblank time
            
            call update_timers
            call update_graphics
            call update_sprites
            halt
            call update_player

        .post_graphics

        UpdateJoypad
        jr .loop