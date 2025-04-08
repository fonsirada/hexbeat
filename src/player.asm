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
def SPRITE_0_ADDRESS equ (_OAMRAM)
def SPRITE_1_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS)
def SPRITE_2_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 2)
def SPRITE_3_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 3)
def SPRITE_4_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 4)
def SPRITE_5_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 5)

def INITIAL_PLAYER_LOC                  equ 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_player:
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

move_player_to_start:
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
init_player_sprite_data:
    copy16bit [$C010], [$C011], _OAMRAM
    copy16bit [$C012], [$C013], _OAMRAM + sizeof_OAM_ATTRS * 1
    copy16bit [$C014], [$C015], _OAMRAM + sizeof_OAM_ATTRS * 2
    copy16bit [$C016], [$C017], _OAMRAM + sizeof_OAM_ATTRS * 3
    copy16bit [$C018], [$C019], _OAMRAM + sizeof_OAM_ATTRS * 4
    copy16bit [$C01A], [$C01B], _OAMRAM + sizeof_OAM_ATTRS * 5

    ret

jump:
    ld a, [rPLAYER]
    bit PLAYERB_FALL, a
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    jr z, .go_up
        add 8
        SetPlayerCoord a, OAMA_Y
        jr .check_thres1

    .go_up
    sub 8
    SetPlayerCoord a, OAMA_Y
    
    ; go back down
    .check_thres1
    cp MC_JUMP_THRES
    jr nz, .check_thres2
        RegBitOp rPLAYER, PLAYERB_FALL, set ; not sure why this is blue...
        jr .return

    ; go back up
    .check_thres2
    cp MC_TOP_Y
    jr nz, .return
        RegBitOp rPLAYER, PLAYERB_FALL, res
    .return
    ret

player_hit_high:
    ld a, [rPLAYER]
    bit PLAYERB_HOLD, a

    jr nz, .extend_frame
        ; go to next frame
        UpdatePlayerAnim $C010, $C01C, $90 
        call jump
        jr .end_frame_update

    .extend_frame
        ; frame 3-4: ($60) + set shield visible
        copy [SPRITE_8_ADDRESS + OAMA_Y], MC_TOP_Y - 20
        copy [SPRITE_8_ADDRESS + OAMA_X], 20 + 24
        RegBitOp rPLAYER, PLAYERB_HOLD, res

    .end_frame_update
    ret

player_hit_low:
    ld a, [rPLAYER]
    bit PLAYERB_HOLD, a

    jr nz, .extend_frame
        ; go to next frame
        UpdatePlayerAnim $C010, $C01C, $60
        jr .end_frame_update

    .extend_frame
        ; frame 3-4: ($60) + set shield visible
        copy [SPRITE_9_ADDRESS + OAMA_Y], MC_TOP_Y + 12
        copy [SPRITE_9_ADDRESS + OAMA_X], 20 + 24
        RegBitOp rPLAYER, PLAYERB_HOLD, res
    
        .end_frame_update
    ret

; updates the player animation based on joypad press
update_player:
    halt 
    halt
    halt

    ; set flags from joypad input
    ProcessInputForAnim PADB_B, PLAYERB_B, $30
    ProcessInputForAnim PADB_A, PLAYERB_A, $60

    ; check if current frame should be held
    ld a, [rPCA_COUNT]
    ;cp a, $4
    ;jr nz, .done_hold_check
    cp a, $3
    jr nz, .done_hold_check
    .raise_hold
        RegBitOp rPLAYER, PLAYERB_HOLD, set
    .done_hold_check

    ; determine which player animation to run
    ld a, [rPLAYER]
    bit PLAYERB_B, a

    jr z, .update_a
        ld a, [rPCA_COUNT]
        cp a, $4
        jr z, .update_a
            SetPlayerCoord MC_TOP_Y, OAMA_Y
            call player_hit_low
            RegOp rPCA_COUNT, inc

            jr .done_update

    .update_a
        bit PLAYERB_A, a
        jr z, .update_run
        
        ld a, [rPCA_COUNT]
        cp a, $4
        jr z, .update_run
            call player_hit_high
            RegOp rPCA_COUNT, inc

            jr .done_update
    
    .update_run
        RegBitOp rPLAYER, PLAYERB_B, res
        RegBitOp rPLAYER, PLAYERB_B, res
    
        SetPlayerCoord MC_TOP_Y, OAMA_Y
        ld a, [rPLAYER]
        res 3, a
        ld [rPLAYER], a

        UpdatePlayerAnim $C010, $C01C, $30

    .done_update
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export jump, update_player, init_player, init_player_sprite_data, move_player_to_start