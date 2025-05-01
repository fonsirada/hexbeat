;
; HEXBEAT (CS-240 World 8)
;
; @file main.asm
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 30, 2025
; @license GNU GPL v3
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
    .initialize_game
    call initialize
    
    .game_loop
        call start
        call update_game
        jp .game_loop