; 
; CS-240 World 5: Basic Game Functionality
;
; @file player.asm
; @author Sydney Chen, Alfonso Rada
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
def HIT_LOW_SHIELD_Y                equ MC_TOP_Y + 16;12
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
    copy16bit [SPRITE_0_A_WRAM_LOCATION], [SPRITE_0_B_WRAM_LOCATION], _OAMRAM
    copy16bit [SPRITE_1_A_WRAM_LOCATION], [SPRITE_1_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 1
    copy16bit [SPRITE_2_A_WRAM_LOCATION], [SPRITE_2_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 2
    copy16bit [SPRITE_3_A_WRAM_LOCATION], [SPRITE_3_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 3
    copy16bit [SPRITE_4_A_WRAM_LOCATION], [SPRITE_4_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 4
    copy16bit [SPRITE_5_A_WRAM_LOCATION], [SPRITE_5_B_WRAM_LOCATION], _OAMRAM + sizeof_OAM_ATTRS * 5

    ret

jump:
    ; check if player should be going up or down
    ld a, [rPLAYER]
    bit PLAYERB_FALL, a
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    jr z, .go_up
        add JUMP_INCREMENT
        SetPlayerCoord a, OAMA_Y
        jr .check_thres1

    .go_up
    sub JUMP_INCREMENT
    SetPlayerCoord a, OAMA_Y
    
    ; go back down
    .check_thres1
    cp MC_JUMP_THRES
    jr nz, .check_thres2
        RegBitOp rPLAYER, PLAYERB_FALL, set
        jr .return

    ; go back up
    .check_thres2
    cp MC_TOP_Y
    jr nz, .return
        RegBitOp rPLAYER, PLAYERB_FALL, res

    .return
    ret

; animation for player hit high
player_hit_high:
    ld a, [rPLAYER]
    bit PLAYERB_HOLD, a
    jr nz, .extend_frame
    
    ld a, [PAD_LHOLD]
    cp 0
    jr z, .extend_frame
        UpdatePlayerAnim SPRITE_0_A_WRAM_LOCATION, SPRITE_ANIM_WRAM_THRES, SPRITE_HIT_HIGH_THRES_TILEID
        call jump
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
    jp nz, .done_update ; must be jp for now

    ; set flags from joypad input
    ProcessInputForAnim PADB_B, PLAYERB_B, SPRITE_RUN_THRES_TILEID
    ProcessInputForAnim PADB_A, PLAYERB_A, SPRITE_HIT_LOW_THRES_TILEID

    ; check if current frame should be held
    ld a, [rPC_ACOUNT]
    cp FRAME_TO_HOLD
    jr nz, .done_hold_check
    .raise_hold
        RegBitOp rPLAYER, PLAYERB_HOLD, set
    .done_hold_check

    ; determine which player animation to run
    ; 'b' button press
    ld a, [rPLAYER]
    bit PLAYERB_B, a
    jr z, .update_a
        ld a, [rPC_ACOUNT]
        cp HIT_ANIM_LENGTH
        jr z, .update_a
            SetPlayerCoord MC_TOP_Y, OAMA_Y
            call player_hit_low
            RegOp rPC_ACOUNT, inc

            jr .done_update

    ; 'a' button press
    .update_a
        bit PLAYERB_A, a
        jr z, .update_run
        
        ld a, [rPC_ACOUNT]
        cp HIT_ANIM_LENGTH
        jr z, .update_run
            call player_hit_high
            RegOp rPC_ACOUNT, inc

            jr .done_update
    
    ; no button press
    .update_run
        RegBitOp rPLAYER, PLAYERB_B, res
        RegBitOp rPLAYER, PLAYERB_B, res
    
        SetPlayerCoord MC_TOP_Y, OAMA_Y
        RegBitOp rPLAYER, PLAYERB_FALL, res

        UpdatePlayerAnim SPRITE_0_A_WRAM_LOCATION, SPRITE_ANIM_WRAM_THRES, SPRITE_RUN_THRES_TILEID

    .done_update
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export jump, update_player, init_player, init_player_sprite_data, move_player_for_level