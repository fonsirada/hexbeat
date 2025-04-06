; header here

; tile conversion commands:
; /Users/sydneychen/Desktop/cs240/aseprite/build/bin/aseprite
; cd ../../gca/tools/conv
; ./gfxconv ../../../cs240\ game/tileset_16mode.png ../../../cs240\ game/w5_window_v1.png ../../../cs240\ game/witch_bg_hall_v1.png

include "src/hardware.inc"
include "src/utils.inc"
include "src/sprites.inc"

section "sprites", rom0

;;;;;;;
InitSpriteData:
    call InitPlayerSpriteData
    ; to-do:
    ; - add 'shield' sprites
    ; - add multiple spell sprites

    ret

InitSprites:
    ; TARGETS
    copy [SPRITE_6_ADDRESS + OAMA_Y], 0
    copy [SPRITE_6_ADDRESS + OAMA_X], 0
    copy [SPRITE_6_ADDRESS + OAMA_TILEID], $4E
    copy [SPRITE_6_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_7_ADDRESS + OAMA_Y], 0
    copy [SPRITE_7_ADDRESS + OAMA_X], 0
    copy [SPRITE_7_ADDRESS + OAMA_TILEID], $5E
    copy [SPRITE_7_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; PLAYER 'SHIELD' SPRITES
    copy [SPRITE_8_ADDRESS + OAMA_Y], 0
    copy [SPRITE_8_ADDRESS + OAMA_X], 0
    copy [SPRITE_8_ADDRESS + OAMA_TILEID], $6E
    copy [SPRITE_8_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_9_ADDRESS + OAMA_Y], 0
    copy [SPRITE_9_ADDRESS + OAMA_X], 0
    copy [SPRITE_9_ADDRESS + OAMA_TILEID], $7E
    copy [SPRITE_9_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; SPELL OBJ SPRITES
    ;-- SPELL 1
    copy [SPRITE_10_ADDRESS + OAMA_Y], 0
    copy [SPRITE_10_ADDRESS + OAMA_X], 0
    copy [SPRITE_10_ADDRESS + OAMA_TILEID], $0E
    copy [SPRITE_10_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_11_ADDRESS + OAMA_Y], 0
    copy [SPRITE_11_ADDRESS + OAMA_X], 0
    copy [SPRITE_11_ADDRESS + OAMA_TILEID], $1E
    copy [SPRITE_11_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ;-- SPELL 2
    copy [SPRITE_12_ADDRESS + OAMA_Y], 0
    copy [SPRITE_12_ADDRESS + OAMA_X], 0
    copy [SPRITE_12_ADDRESS + OAMA_TILEID], $2E
    copy [SPRITE_12_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_13_ADDRESS + OAMA_Y], 0
    copy [SPRITE_13_ADDRESS + OAMA_X], 0
    copy [SPRITE_13_ADDRESS + OAMA_TILEID], $3E
    copy [SPRITE_13_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ret

MoveSpritesToStart:
    copy [SPRITE_6_ADDRESS + OAMA_Y], MC_TOP_Y - 16
    copy [SPRITE_6_ADDRESS + OAMA_X], 20 + 32

    copy [SPRITE_7_ADDRESS + OAMA_Y], MC_TOP_Y + 16
    copy [SPRITE_7_ADDRESS + OAMA_X], 20 + 32

    copy [SPRITE_10_ADDRESS + OAMA_Y], MC_TOP_Y - 20
    copy [SPRITE_10_ADDRESS + OAMA_X], 0

    copy [SPRITE_11_ADDRESS + OAMA_Y], MC_TOP_Y - 20
    copy [SPRITE_11_ADDRESS + OAMA_X], 0


UpdateSprites:
    ; scrolling spell 1
    ld a, [SPRITE_10_ADDRESS + OAMA_X]
    dec a
    dec a
    dec a
    dec a
    ld [SPRITE_10_ADDRESS + OAMA_X], a
    add a, 8
    ld [SPRITE_11_ADDRESS + OAMA_X], a

    ret


export InitSpriteData, InitSprites, UpdateSprites, MoveSpritesToStart