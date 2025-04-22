;
; CS-240 World 6: Fully functional draft
;
; @file main.asm
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 16, 2025
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

; ; temp main while testing sound implementation
main:
    .initialize_game
    DisableLCD

    call init_sound
    call init_graphics
    call init_registers
    call init_sprite_data
    call init_player
    call init_sprites
    InitJoypad

    EnableLCD

    .game_loop
    call start

    ; check if game started
    ld a, [rGAME]
    bit GAMEB_START, a
    jr z, .post_graphics
        ; check if game ended
        bit GAMEB_END, a
        jr z, .graphics
            ; set up game over screen
            call game_over
            ld a, [rGAME]
            bit GAMEB_END, a
            jr z, .initialize_game
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
    call UpdateSample ; swap to update_sound eventually
    UpdateJoypad
    jp .game_loop


/*
main:
    .initialize_game
    DisableLCD

    call init_graphics
    call init_registers
    call init_sprite_data
    call init_player
    call init_sprites
    InitJoypad

    EnableLCD

    .game_loop
        call start

        ; check if game started
        ld a, [rGAME]
        bit GAMEB_START, a
        jr z, .post_graphics
            ; check if game ended
            bit GAMEB_END, a
            jr z, .graphics
                ; set up game over screen
                call game_over
                ld a, [rGAME]
                bit GAMEB_END, a
                jr z, .initialize_game
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
*/