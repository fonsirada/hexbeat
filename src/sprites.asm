; header here

; tile conversion commands:
; /Users/sydneychen/Desktop/cs240/aseprite/build/bin/aseprite
; cd ../../gca/tools/conv
; ./gfxconv ../../../cs240\ game/tileset_16mode.png ../../../cs240\ game/w5_window_v1.png ../../../cs240\ game/witch_bg_hall_v1.png

include "src/hardware.inc"
include "src/utils.inc"

section "sprites", rom0

;; CONST
def SPRITE_0_ADDRESS equ (_OAMRAM)
def SPRITE_1_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS)
def SPRITE_2_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 2)
def SPRITE_3_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 3)
def SPRITE_4_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 4)
def SPRITE_5_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 5)

def MC_TOP_Y equ (80)
def MC_BOT_Y equ (MC_TOP_Y + 16)

;;;;;;;
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
InitPlayerSpriteLocation:
    copy16bit [$C010], [$C011], _OAMRAM
    copy16bit [$C012], [$C013], _OAMRAM + sizeof_OAM_ATTRS * 1
    copy16bit [$C014], [$C015], _OAMRAM + sizeof_OAM_ATTRS * 2
    copy16bit [$C016], [$C017], _OAMRAM + sizeof_OAM_ATTRS * 3
    copy16bit [$C018], [$C019], _OAMRAM + sizeof_OAM_ATTRS * 4
    copy16bit [$C01A], [$C01B], _OAMRAM + sizeof_OAM_ATTRS * 5

    ret



    
;;;;;;;

export InitPlayer, InitPlayerSpriteLocation, MovePlayerToStart