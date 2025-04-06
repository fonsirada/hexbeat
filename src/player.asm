; insert header

include "src/hardware.inc"
include "src/sprites.inc"

section "player", rom0

Jump:
    ; sprites 0 1 2 and 3 4 5 have same Y respectively - $10 off
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    ld b, 20
    .go_up
        dec a
        dec a
        halt
        ld [SPRITE_0_ADDRESS + OAMA_Y], a
        ld [SPRITE_1_ADDRESS + OAMA_Y], a
        ld [SPRITE_2_ADDRESS + OAMA_Y], a
        add $10
        ld [SPRITE_3_ADDRESS + OAMA_Y], a
        ld [SPRITE_4_ADDRESS + OAMA_Y], a
        ld [SPRITE_5_ADDRESS + OAMA_Y], a
        sub $10
        dec b
        jr nz, .go_up
    
    ld b, 20
    .go_down
        inc a
        inc a
        halt 
        ld [SPRITE_0_ADDRESS + OAMA_Y], a
        ld [SPRITE_1_ADDRESS + OAMA_Y], a
        ld [SPRITE_2_ADDRESS + OAMA_Y], a
        add $10
        ld [SPRITE_3_ADDRESS + OAMA_Y], a
        ld [SPRITE_4_ADDRESS + OAMA_Y], a
        ld [SPRITE_5_ADDRESS + OAMA_Y], a
        sub $10
        dec b
        jr nz, .go_down
    
    ret

;;;;;
export Jump