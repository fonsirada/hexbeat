; 
; CS-240 World 5: Basic Game Functionality
;
; @file sprites.asm
; @author Sydney Chen, Alfonso Rada
; @date April 7, 2025
; @brief storing non-player sprite functions

include "src/hardware.inc"
include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "sprites", rom0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def TARGET_HIGH_TILEID     equ $4E
def TARGET_LOW_TILEID      equ $5E
def SHIELD_HIGH_TILEID     equ $6E
def SHIELD_LOW_TILEID      equ $7E
def SPELL1A_TILEID         equ $0E
def SPELL1B_TILEID         equ $1E
def SPELL2A_TILEID         equ $2E
def SPELL2B_TILEID         equ $3E

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; place sprite locations into WRAM
init_sprite_data:
    call init_player_sprite_data

    ; put spell flags into WRAM
    ld hl, SPELL_FLAG_START
    .load_spell_flag
        ld a, 0
        ld [hli], a
        ld a, l
        cp a, low(SPELL_WRAM_START)
        jr nz, .load_spell_flag

    ; put spell sprite addresses into WRAM
    ld hl, SPELL_WRAM_START
    copy16bit [hli], [hli], SPRITE_10_ADDRESS
    copy16bit [hli], [hli], SPRITE_11_ADDRESS
    copy16bit [hli], [hli], SPRITE_12_ADDRESS
    copy16bit [hli], [hli], SPRITE_13_ADDRESS
    copy16bit [hli], [hli], SPRITE_14_ADDRESS
    copy16bit [hli], [hli], SPRITE_15_ADDRESS
    copy16bit [hli], [hli], SPRITE_16_ADDRESS
    copy16bit [hli], [hli], SPRITE_17_ADDRESS
    
    ret

; initalize sprites and their attributes
; format: sprite #, (x, y), tile ID, palette mode
init_sprites:
    ; TARGETS
    SetSpriteData 6, 0, 0, TARGET_HIGH_TILEID, OAMF_PAL0
    SetSpriteData 7, 0, 0, TARGET_LOW_TILEID, OAMF_PAL0

    ; PLAYER 'SHIELD' SPRITES
    SetSpriteData 8, 0, 0, SHIELD_HIGH_TILEID, OAMF_PAL0
    SetSpriteData 9, 0, 0, SHIELD_LOW_TILEID, OAMF_PAL0

    ; SPELL OBJ SPRITES
    SetSpriteData 10, 0, 0, SPELL1A_TILEID, OAMF_PAL0
    SetSpriteData 11, 0, 0, SPELL1B_TILEID, OAMF_PAL0

    SetSpriteData 12, 0, 0, SPELL2A_TILEID, OAMF_PAL0
    SetSpriteData 13, 0, 0, SPELL2B_TILEID, OAMF_PAL0

    SetSpriteData 14, 0, 0, SPELL1A_TILEID, OAMF_PAL0
    SetSpriteData 15, 0, 0, SPELL1B_TILEID, OAMF_PAL0

    SetSpriteData 16, 0, 0, SPELL2A_TILEID, OAMF_PAL0
    SetSpriteData 17, 0, 0, SPELL2B_TILEID, OAMF_PAL0

    ret

move_sprites_for_level:
    ; TARGETS
    SetSpriteXY 6, TARGET_X, TARGET_HIGH_Y
    SetSpriteXY 7, TARGET_X, TARGET_LOW_Y

    ; SPELL OBJs
    SetSpriteXY 10, 0, SPELL_HIGH_Y
    SetSpriteXY 11, 0, SPELL_HIGH_Y
    SetSpriteXY 12, 128, SPELL_LOW_Y
    SetSpriteXY 13, 128, SPELL_LOW_Y
    SetSpriteXY 14, 64, SPELL_HIGH_Y
    SetSpriteXY 15, 64, SPELL_HIGH_Y

    ret

; NOTE: returns hl and de for handle_collision and handle_miss
update_sprites:
    CheckTimer rTIMER_OBJ, 1
    jr nz, .done_update

    ld hl, SPELL_WRAM_START
    .update_spell_sprite
        ; preserve hl and store in de
        push hl
        ld d, h
        ld e, l

        ; load spell_a address into (hl)
        WRAMToOAM hl
        ld b, $00
        ld c, OAMA_X
        add hl, bc

        ; preserve pt 1
        push hl

        ; load in new x val
        ld a, [hl]
        sub SPELL_SCROLL_SPEED
        ld [hl], a

        ; load spell_b address into (hl)
        ld h, d
        ld l, e
        inc hl
        inc hl
        WRAMToOAM hl
        ld b, $00
        ld c, OAMA_X
        add hl, bc

        ; load offset x val for sprite pt 2
        add a, OBJ16_OFFSET
        ld [hl], a

        ;NOTE: this method requires an extra halt in main
        ; preserve pt 2
        push hl

        ; get 2nd sprite part
        pop hl
        ld d, h
        ld e, l

        ; get 1st sprite part
        pop hl
        call check_collisions

        ; to next spell sprite
        pop hl
        inc hl
        inc hl
        inc hl
        inc hl
        
        ld a, l
        cp a, $3C;$38; $40 ;change here for # of active sprites
        jr nz, .update_spell_sprite

        ; try flag vals to 

    SetShieldLocations 0, 0, 0, 0
    .done_update
    ret

check_collisions:
    ; raise miss flag by default
    copy [rCOLLISION], COLLF_XMISS

    ; check if the current x is within the 'perfect' x range
    ; set perf flag if so
    CheckSpriteRange [hl]
    ; [SPRITE_10_ADDRESS + OAMA_X], HIT_PERF_MIN, HIT_PERF_MAX, rCOLLB_XPERF

    ld a, [PAD_CURR]
    bit PADB_B, a
        jr z, .run_check
    bit PADB_A, a
        jr nz, .check_miss
    ; if PADB_B or PADB_A are true, continue
    ; NOTE: A and B will run this regardless of high/low match

    .run_check 
    ;jr nz, .check_miss
        ld a, [rCOLLISION]
        bit COLLB_XPERF, a
        jr z, .check_miss
            call handle_collision
            jr .done_check
    
    .check_miss
        call handle_miss
    .done_check
    ret


handle_collision:
    ld a, 0
    ld [hl], a
    ld [de], a
    ; set 'inactive' flag?

    ld a, [rGAME_DIFF]
    inc a
    ld [rGAME_DIFF], a
    ret

handle_miss:
    ; will be called if no button is pressed
    ; note: change so x val comparison is outside func call?
    ; note: eventually flash the player sprite (damage)
    ld a, [hl]; [SPRITE_10_ADDRESS + OAMA_X]
    cp a, 4
    jr nc, .done
        ; lower player health
        ld a, [rPC_HEALTH]
        dec a
        ld [rPC_HEALTH], a

        cp a, 0
        jr nz, .done
            RegBitOp rGAME, GAMEB_END, set
            ; note: may want to move this if we have diff hazards
    .done
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sprite_data, init_sprites, update_sprites, move_sprites_for_level