; 
; CS-240 World 8: Your final, polished game
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

; player sprite locations in WRAM
rsset _RAM + $14
def PC_0A_WRAM       rb 1
def PC_0B_WRAM       rb 1
def PC_1A_WRAM       rb 1
def PC_1B_WRAM       rb 1
def PC_2A_WRAM       rb 1
def PC_2B_WRAM       rb 1
def PC_3A_WRAM       rb 1
def PC_3B_WRAM       rb 1
def PC_4A_WRAM       rb 1
def PC_4B_WRAM       rb 1
def PC_5A_WRAM       rb 1
def PC_5B_WRAM       rb 1


def JUMP_INCREMENT                  equ 8
def JUMP_HOLD_Y                     equ 60

; no more sprites at and including this wram address
def SPRITE_ANIM_WRAM_THRES          equ PC_5B_WRAM + 1
; hit high animation stops at this tile
def SPRITE_HIT_HIGH_THRES_TILEID    equ $90
; hit low animation stops AND hit high animation begins at this tile
def SPRITE_HIT_LOW_THRES_TILEID     equ $60
; run animation stops AND hit low animation begins at this tile
def SPRITE_RUN_THRES_TILEID         equ $30

def HIT_HIGH_SHIELD_Y               equ PC_TOP_Y - 20
def HIT_LOW_SHIELD_Y                equ PC_TOP_Y + 16
def SHIELD_X                        equ 44

def FRAME_TO_HOLD                   equ $3
def HIT_ANIM_LENGTH                 equ $4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; updates the Player sprite(s) to the next frame
; by looping thru sprite locations stored in WRAM
; run as: UpdatePlayerAnim (WRAM start address, WRAM end address, ending tileID)
; ex: UpdatePlayerAnim $C010, $C01C, $30
macro UpdatePlayerAnim
    push af
    push bc
    push hl

    ld hl, \1

    ; loop through sprites thru WRAM address locs
    .next_tile
        push hl

        ;; LOAD TILE ID ;;
        ; store sprite address in hl
        ld b, [hl]
        inc hl
        ld c, [hl]
        ld h, b
        ld l, c

        ; get sprite's tileID address
        ld a, l
        add OAMA_TILEID
        ld l, a
        ld a, [hl] 

        ; change tileID as appropriate
        cp \3
        jr c, .load_new_tileid
            sub \3
            jr .finish_tile_load

        .load_new_tileid
            add PC_VRAM_ANIM_INT

        .finish_tile_load
        ld [hli], a

        ;; FLASH PALETTE ;;
        ld a, [rTIMER_DMG]
        or a
        jr z, .no_flash
            cp (PC_DMG_COUNT + 1)
            jr nc, .no_flash
                dec a
                ld [rTIMER_DMG], a

                ld a, [hl]
                xor OAMF_PAL1
                ld [hl], a
                jr .done_flash
        .no_flash
            ld a, [hl]
            and OAMF_PAL0
            ld [hl], a
        .done_flash

        ; go to next tile in WRAM
        pop hl
        inc hl
        inc hl
    
        ; check if last sprite was reached in WRAM
        ld a, l
        cp low(\2)
        jr nz, .next_tile

    .end_update
    pop hl
    pop bc
    pop af
endm

; set the Player sprite(s)'s tileIDs based on the first sprite
macro SetPlayerTiles
   copy [SPRITE_0_ADDRESS + OAMA_TILEID], \1
   copy [SPRITE_1_ADDRESS + OAMA_TILEID], \1 + 2
   copy [SPRITE_2_ADDRESS + OAMA_TILEID], \1 + 4
   copy [SPRITE_3_ADDRESS + OAMA_TILEID], \1 + 6
   copy [SPRITE_4_ADDRESS + OAMA_TILEID], \1 + 8
   copy [SPRITE_5_ADDRESS + OAMA_TILEID], \1 + 10
endm

; set the Player sprite(s)'s X or Y value based on the first sprite
macro SetPlayerCoord
    ld a, \1
    ld [SPRITE_0_ADDRESS + \2], a
    ld [SPRITE_1_ADDRESS + \2], a
    ld [SPRITE_2_ADDRESS + \2], a
    add PC_VRAM_ANIM_INT
    ld [SPRITE_3_ADDRESS + \2], a
    ld [SPRITE_4_ADDRESS + \2], a
    ld [SPRITE_5_ADDRESS + \2], a
    sub PC_VRAM_ANIM_INT
endm

; set 'shield' sprite locations in form (x1, y1), (x2, y2)
macro SetShieldLocations
    copy [SPRITE_8_ADDRESS + OAMA_X], \1
    copy [SPRITE_8_ADDRESS + OAMA_Y], \2
    
    copy [SPRITE_9_ADDRESS + OAMA_X], \3
    copy [SPRITE_9_ADDRESS + OAMA_Y], \4
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_player:
    ; PC.00
    copy [SPRITE_0_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_0_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_0_ADDRESS + OAMA_TILEID], SPRITE_0_TILEID
    copy [SPRITE_0_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; PC.01
    copy [SPRITE_1_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_1_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_1_ADDRESS + OAMA_TILEID], SPRITE_1_TILEID
    copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; PC.02
    copy [SPRITE_2_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_2_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_2_ADDRESS + OAMA_TILEID], SPRITE_2_TILEID
    copy [SPRITE_2_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; PC.10
    copy [SPRITE_3_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_3_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_3_ADDRESS + OAMA_TILEID], SPRITE_3_TILEID
    copy [SPRITE_3_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; PC.11
    copy [SPRITE_4_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_4_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_4_ADDRESS + OAMA_TILEID], SPRITE_4_TILEID
    copy [SPRITE_4_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; PC.12
    copy [SPRITE_5_ADDRESS + OAMA_Y], INITIAL_PLAYER_XY
    copy [SPRITE_5_ADDRESS + OAMA_X], INITIAL_PLAYER_XY
    copy [SPRITE_5_ADDRESS + OAMA_TILEID], SPRITE_5_TILEID
    copy [SPRITE_5_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ret

move_player_for_level:
    ; PC.00
    copy [SPRITE_0_ADDRESS + OAMA_Y], PC_TOP_Y
    copy [SPRITE_0_ADDRESS + OAMA_X], SPRITE_0_3_LEVEL_X

    ; PC.01
    copy [SPRITE_1_ADDRESS + OAMA_Y], PC_TOP_Y
    copy [SPRITE_1_ADDRESS + OAMA_X], SPRITE_1_4_LEVEL_X

    ; PC.02
    copy [SPRITE_2_ADDRESS + OAMA_Y], PC_TOP_Y
    copy [SPRITE_2_ADDRESS + OAMA_X], SPRITE_2_5_LEVEL_X

    ; PC.10
    copy [SPRITE_3_ADDRESS + OAMA_Y], PC_BOT_Y
    copy [SPRITE_3_ADDRESS + OAMA_X], SPRITE_0_3_LEVEL_X

    ; PC.11
    copy [SPRITE_4_ADDRESS + OAMA_Y], PC_BOT_Y
    copy [SPRITE_4_ADDRESS + OAMA_X], SPRITE_1_4_LEVEL_X

    ; PC.12
    copy [SPRITE_5_ADDRESS + OAMA_Y], PC_BOT_Y
    copy [SPRITE_5_ADDRESS + OAMA_X], SPRITE_2_5_LEVEL_X

    ret

; put PC sprite ids in WRAM
init_player_sprite_data:
    Copy16BitVal [PC_0A_WRAM], [PC_0B_WRAM], _OAMRAM
    Copy16BitVal [PC_1A_WRAM], [PC_1B_WRAM], _OAMRAM + sizeof_OAM_ATTRS * 1
    Copy16BitVal [PC_2A_WRAM], [PC_2B_WRAM], _OAMRAM + sizeof_OAM_ATTRS * 2
    Copy16BitVal [PC_3A_WRAM], [PC_3B_WRAM], _OAMRAM + sizeof_OAM_ATTRS * 3
    Copy16BitVal [PC_4A_WRAM], [PC_4B_WRAM], _OAMRAM + sizeof_OAM_ATTRS * 4
    Copy16BitVal [PC_5A_WRAM], [PC_5B_WRAM], _OAMRAM + sizeof_OAM_ATTRS * 5
    ret

; animation for player hit high
player_hit_high:
    ld a, [rPLAYER]
    bit PLAYERB_HOLD, a
    jr nz, .extend_frame
        UpdatePlayerAnim PC_0A_WRAM, SPRITE_ANIM_WRAM_THRES, SPRITE_HIT_HIGH_THRES_TILEID
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
        UpdatePlayerAnim PC_0A_WRAM, SPRITE_ANIM_WRAM_THRES, SPRITE_HIT_LOW_THRES_TILEID
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

    ; set correct flags/registers/tileIDs from joypad input
    ld a, [PAD_CURR]
    bit PADB_B, a
    jr nz, .done_b
        RegBitOp rPLAYER, PLAYERB_B, set
        RegBitOp rPLAYER, PLAYERB_A, res
        SetPlayerTiles SPRITE_RUN_THRES_TILEID
    .done_b
    ld a, [PAD_CURR]
    bit PADB_A, a
    jr nz, .done_a
        RegBitOp rPLAYER, PLAYERB_A, set
        RegBitOp rPLAYER, PLAYERB_B, res
        SetPlayerTiles SPRITE_HIT_LOW_THRES_TILEID
    .done_a

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
        ; reset anim count to 0 if full animation and extra frame hold has been reached
        jr nz, .update_anim_b
            copy [rPC_ACOUNT], 0
            jr .update_a

        .update_anim_b
            SetPlayerCoord PC_TOP_Y, OAMA_Y
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
            ; long hold functionality
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
        SetPlayerCoord PC_TOP_Y, OAMA_Y
        UpdatePlayerAnim PC_0A_WRAM, SPRITE_ANIM_WRAM_THRES, SPRITE_RUN_THRES_TILEID

    .done_update
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export update_player, init_player, init_player_sprite_data, move_player_for_level