; insert header

include "src/hardware.inc"
include "src/utils.inc"
include "src/sprites.inc"

section "player", rom0

InitPlayer:
    ; MC.00
    copy [SPRITE_0_ADDRESS + OAMA_Y], 0
    copy [SPRITE_0_ADDRESS + OAMA_X], 0
    copy [SPRITE_0_ADDRESS + OAMA_TILEID], 0
    copy [SPRITE_0_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.01
    copy [SPRITE_1_ADDRESS + OAMA_Y], 0
    copy [SPRITE_1_ADDRESS + OAMA_X], 0
    copy [SPRITE_1_ADDRESS + OAMA_TILEID], 2
    copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.02
    copy [SPRITE_2_ADDRESS + OAMA_Y], 0
    copy [SPRITE_2_ADDRESS + OAMA_X], 0
    copy [SPRITE_2_ADDRESS + OAMA_TILEID], 4
    copy [SPRITE_2_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.10
    copy [SPRITE_3_ADDRESS + OAMA_Y], 0
    copy [SPRITE_3_ADDRESS + OAMA_X], 0
    copy [SPRITE_3_ADDRESS + OAMA_TILEID], 6
    copy [SPRITE_3_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.11
    copy [SPRITE_4_ADDRESS + OAMA_Y], 0
    copy [SPRITE_4_ADDRESS + OAMA_X], 0
    copy [SPRITE_4_ADDRESS + OAMA_TILEID], 8
    copy [SPRITE_4_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.12
    copy [SPRITE_5_ADDRESS + OAMA_Y], 0
    copy [SPRITE_5_ADDRESS + OAMA_X], 0
    copy [SPRITE_5_ADDRESS + OAMA_TILEID], 10
    copy [SPRITE_5_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ret

MovePlayerToStart:
    ; MC.00
    copy [SPRITE_0_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_0_ADDRESS + OAMA_X], 20

    ; MC.01
    copy [SPRITE_1_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_1_ADDRESS + OAMA_X], 28

    ; MC.02
    copy [SPRITE_2_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_2_ADDRESS + OAMA_X], 36

    ; MC.10
    copy [SPRITE_3_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_3_ADDRESS + OAMA_X], 20

    ; MC.11
    copy [SPRITE_4_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_4_ADDRESS + OAMA_X], 28

    ; MC.12
    copy [SPRITE_5_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_5_ADDRESS + OAMA_X], 36

    ret

; put PC sprite ids in WRAM
InitPlayerSpriteData:
    copy16bit [$C010], [$C011], _OAMRAM
    copy16bit [$C012], [$C013], _OAMRAM + sizeof_OAM_ATTRS * 1
    copy16bit [$C014], [$C015], _OAMRAM + sizeof_OAM_ATTRS * 2
    copy16bit [$C016], [$C017], _OAMRAM + sizeof_OAM_ATTRS * 3
    copy16bit [$C018], [$C019], _OAMRAM + sizeof_OAM_ATTRS * 4
    copy16bit [$C01A], [$C01B], _OAMRAM + sizeof_OAM_ATTRS * 5

    ret

Jump:
    ; sprites 0 1 2 and 3 4 5 have same Y respectively - $10 off
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    ld b, 16
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
    
    ld b, 16
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


UpdatePlayer:
    halt 
    halt
    halt
    ; if [A] pressed, run HighHit macro
    ; if [B] pressed, run LowHit macro
    ; else, update run
    ; *macro to restore run anim sprite addresses
    UpdateRunAnim
    ;

    ret

;;;;;
export Jump, UpdatePlayer, InitPlayer, InitPlayerSpriteData, MovePlayerToStart