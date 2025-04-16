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

    call init_registers
    call init_sprite_data
    call init_player
    call init_sprites
    InitJoypad

    EnableLCD
    /*
    .start_screen
        call start
        UpdateJoypad
        jr nz, .start_screen
    */

    .game_loop
        ; set up title screen
        call start

        ld a, [rGAME]
        bit GAMEB_START, a
        ; if game hasn't been started yet, jump to updatejoypad to read 'start' press
        jr z, .post_graphics
            bit GAMEB_END, a
            ; if game has been started, but not ended, just update graphics
            jr z, .graphics
                ; if game has been ended, set up game over screen
                call game_over
                jr .post_graphics

        .graphics
            call update_timers
            call update_graphics
            halt
            call update_sprites
            halt
            call update_player
            call check_level_2
        .post_graphics
        UpdateJoypad
        jp .game_loop