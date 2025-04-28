; 
; CS-240 World 7: Feature complete game
;
; @file player.asm
; @author Sydney Chen, Alfonso Rada
; @date April 24, 2025
; @brief storing player functions

include "src/hardware.inc"
include "src/utils.inc"
include "src/joypad.inc"
include "src/sprites.inc"
include "src/wram.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "player", rom0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; player sprites
def SPRITE_0_ADDRESS                equ (_OAMRAM)
def SPRITE_1_ADDRESS                equ (_OAMRAM + sizeof_OAM_ATTRS)
def SPRITE_2_ADDRESS                equ (_OAMRAM + sizeof_OAM_ATTRS * 2)
def SPRITE_3_ADDRESS                equ (_OAMRAM + sizeof_OAM_ATTRS * 3)
def SPRITE_4_ADDRESS                equ (_OAMRAM + sizeof_OAM_ATTRS * 4)
def SPRITE_5_ADDRESS                equ (_OAMRAM + sizeof_OAM_ATTRS * 5)

def INITIAL_PLAYER_XY               equ 0

def SPRITE_0_TILEID                 equ 0
def SPRITE_1_TILEID                 equ 2
def SPRITE_2_TILEID                 equ 4
def SPRITE_3_TILEID                 equ 6
def SPRITE_4_TILEID                 equ 8
def SPRITE_5_TILEID                 equ 10

def SPRITE_0_3_LEVEL_X              equ 20
def SPRITE_1_4_LEVEL_X              equ 28
def SPRITE_2_5_LEVEL_X              equ 36

; location of 1st player sprite
def SPRITE_0_A_WRAM_LOCATION        equ $C010
def SPRITE_0_B_WRAM_LOCATION        equ $C011
def SPRITE_1_A_WRAM_LOCATION        equ $C012
def SPRITE_1_B_WRAM_LOCATION        equ $C013
def SPRITE_2_A_WRAM_LOCATION        equ $C014
def SPRITE_2_B_WRAM_LOCATION        equ $C015
def SPRITE_3_A_WRAM_LOCATION        equ $C016
def SPRITE_3_B_WRAM_LOCATION        equ $C017
def SPRITE_4_A_WRAM_LOCATION        equ $C018
def SPRITE_4_B_WRAM_LOCATION        equ $C019
def SPRITE_5_A_WRAM_LOCATION        equ $C01A
def SPRITE_5_B_WRAM_LOCATION        equ $C01B

def JUMP_INCREMENT                  equ 8
def JUMP_HOLD_Y                     equ 60

; no more sprites at and including this wram address
def SPRITE_ANIM_WRAM_THRES          equ $C01C
; hit high animation stops at this tile
def SPRITE_HIT_HIGH_THRES_TILEID    equ $90
; hit low animation stops AND hit high animation begins at this tile
def SPRITE_HIT_LOW_THRES_TILEID     equ $60
; run animation stops AND hit low animation begins at this tile
def SPRITE_RUN_THRES_TILEID         equ $30

def HIT_HIGH_SHIELD_Y               equ MC_TOP_Y - 20
def HIT_LOW_SHIELD_Y                equ MC_TOP_Y + 16
def SHIELD_X                        equ 44

def FRAME_TO_HOLD                   equ $3
def HIT_ANIM_LENGTH                 equ $4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_player:
    ; MC.00
    copy [SPRITE_0_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_0_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_0_ADDRESS + OAMA_TILEID], SPRITE_0_TILEID
    copy [SPRITE_0_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.01
    copy [SPRITE_1_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_1_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_1_ADDRESS + OAMA_TILEID], SPRITE_1_TILEID
    copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.02
    copy [SPRITE_2_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_2_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_2_ADDRESS + OAMA_TILEID], SPRITE_2_TILEID
    copy [SPRITE_2_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.10
    copy [SPRITE_3_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_3_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_3_ADDRESS + OAMA_TILEID], SPRITE_3_TILEID
    copy [SPRITE_3_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.11
    copy [SPRITE_4_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_4_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_4_ADDRESS + OAMA_TILEID], SPRITE_4_TILEID
    copy [SPRITE_4_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.12
    copy [SPRITE_5_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_5_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_5_ADDRESS + OAMA_TILEID], SPRITE_5_TILEID
    copy [SPRITE_5_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ret

move_player_for_level:
    ; MC.00
    copy [SPRITE_0_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_0_ADDRESS + OAMA_X], SPRITE_0_3_LEVEL_X

    ; MC.01
    copy [SPRITE_1_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_1_ADDRESS + OAMA_X], SPRITE_1_4_LEVEL_X

    ; MC.02
    copy [SPRITE_2_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_2_ADDRESS + OAMA_X], SPRITE_2_5_LEVEL_X

    ; MC.10
    copy [SPRITE_3_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_3_ADDRESS + OAMA_X], SPRITE_0_3_LEVEL_X

    ; MC.11
    copy [SPRITE_4_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_4_ADDRESS + OAMA_X], SPRITE_1_4_LEVEL_X

    ; MC.12
    copy [SPRITE_5_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_5_ADDRESS + OAMA_X], SPRITE_2_5_LEVEL_X

    ret

; put PC sprite ids in WRAM
init_player_sprite_data:
    Copy16BitVal [SPRITE_0_A_WRAM_LOCATION], [SPRITE_0_B_WRAM_LOCATION], _OAMRAM
    Copy16BitVal [SPRITE_1_A_WRAM_LOCATION], [SPRITE_1_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 1
    Copy16BitVal [SPRITE_2_A_WRAM_LOCATION], [SPRITE_2_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 2
    Copy16BitVal [SPRITE_3_A_WRAM_LOCATION], [SPRITE_3_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 3
    Copy16BitVal [SPRITE_4_A_WRAM_LOCATION], [SPRITE_4_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 4
    Copy16BitVal [SPRITE_5_A_WRAM_LOCATION], [SPRITE_5_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 5
    ret

; animation for player hit high
player_hit_high:
    ld a, [rPLAYER]
    bit PLAYERB_HOLD, a
    jr nz, .extend_frame
        UpdatePlayerAnim SPRITE_0_A_WRAM_LOCATION, SPRITE_ANIM_WRAM_THRES, SPRITE_HIT_HIGH_THRES_TILEID
        jr .end_frame_update

    .extend_frame
    ; set player frame to $90
    SetPlayerTiles SPRITE_HIT_HIGH_THRES_TILEID
    SetPlayerCoord JUMP_HOLD_Y, OAMA_Y
    ; set shield visible
    copy [SPRITE_8_ADDRESS + OAMA_Y], HIT_HIGH_SHIELD_Y
    copy [SPRITE_8_ADDRESS + OAMA_X], SHIELD_X
    RegBitOp rPLAYER, PLAYERB_HOLD, res

    .end_frame_update
    ret

; animation for player hit low
player_hit_low:
    ld a, [rPLAYER]
    bit PLAYERB_HOLD, a
    jr nz, .extend_frame
        UpdatePlayerAnim SPRITE_0_A_WRAM_LOCATION, SPRITE_ANIM_WRAM_THRES, SPRITE_HIT_LOW_THRES_TILEID
        jr .end_frame_update

    .extend_frame
    ; set player frame to $60
    SetPlayerTiles SPRITE_HIT_LOW_THRES_TILEID

    ; frame 3-4: ($60) + set shield visible
    copy [SPRITE_9_ADDRESS + OAMA_Y], HIT_LOW_SHIELD_Y
    copy [SPRITE_9_ADDRESS + OAMA_X], SHIELD_X
    RegBitOp rPLAYER, PLAYERB_HOLD, res
    
    .end_frame_update
    ret

; updates the player animation based on joypad press
update_player:
    CheckTimer rTIMER_PC, 1
    ; must be jp for now
    jp nz, .done_update 
    SetShieldLocations 0, 0, 0, 0

    ; set flags from joypad input
    ProcessInputForAnim PADB_B, PLAYERB_B, SPRITE_RUN_THRES_TILEID
    ProcessInputForAnim PADB_A, PLAYERB_A, SPRITE_HIT_LOW_THRES_TILEID

    ; check if current frame should be held (4th frame)
    ld a, [rPC_ACOUNT]
    cp FRAME_TO_HOLD
    jr nz, .done_hold_check
        RegBitOp rPLAYER, PLAYERB_HOLD, set

    .done_hold_check
    ; animation for B Button Press - player hit low
    ld a, [rPLAYER]
    bit PLAYERB_B, a
    jr z, .update_a
        ld a, [rPC_ACOUNT]
        cp HIT_ANIM_LENGTH
        ; reset ACOUNT to 0 if full animation and extra frame hold has been reached
        jr nz, .update_anim_b
            copy [rPC_ACOUNT], 0
            jr .update_a

        .update_anim_b
        SetPlayerCoord MC_TOP_Y, OAMA_Y
        call player_hit_low
        RegOp rPC_ACOUNT, inc
        jp .done_update 

    ; animation for A Button Press - player hit high
    .update_a
    bit PLAYERB_A, a
    jp z, .update_run
        ld a, [rPC_ACOUNT]
        cp HIT_ANIM_LENGTH
        jr nz, .update_anim_a
            ld a, [PAD_LHOLD]
            or a
            jr z, .hold_last_frame
                copy [rPC_ACOUNT], 0
                jr .update_run

            .hold_last_frame
            SetPlayerTiles SPRITE_HIT_HIGH_THRES_TILEID
            SetPlayerCoord JUMP_HOLD_Y, OAMA_Y
            copy [SPRITE_8_ADDRESS + OAMA_Y], HIT_HIGH_SHIELD_Y
            copy [SPRITE_8_ADDRESS + OAMA_X], SHIELD_X
            jp .done_update

        .update_anim_a
        SetPlayerCoord JUMP_HOLD_Y, OAMA_Y
        call player_hit_high
        RegOp rPC_ACOUNT, inc
        jr .done_update
    
    ; no button press - player runs
    .update_run
    RegBitOp rPLAYER, PLAYERB_B, res
    RegBitOp rPLAYER, PLAYERB_A, res
    SetPlayerCoord MC_TOP_Y, OAMA_Y
    UpdatePlayerAnim SPRITE_0_A_WRAM_LOCATION, SPRITE_ANIM_WRAM_THRES, SPRITE_RUN_THRES_TILEID

    .done_update
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export jump, update_player, init_player, init_player_sprite_data, move_player_for_level