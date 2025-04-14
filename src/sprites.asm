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
    
    
    ; is there a way to make this work...?
    ; loop ver of spell wram loading
    /*
    ld 10, b
    .load_sprite_address
        copy16bit [hli], [hli], _OAMRAM + sizeof_OAM_ATTRS * b
        inc b

        ld a, b
        cp a, 18
        jr nz, .load_sprite_address
    */
    ret

; initalize sprites and their attributes
init_sprites:
    ; TARGETS
    copy [SPRITE_6_ADDRESS + OAMA_Y], 0
    copy [SPRITE_6_ADDRESS + OAMA_X], 0
    copy [SPRITE_6_ADDRESS + OAMA_TILEID], TARGET_HIGH_TILEID
    copy [SPRITE_6_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_7_ADDRESS + OAMA_Y], 0
    copy [SPRITE_7_ADDRESS + OAMA_X], 0
    copy [SPRITE_7_ADDRESS + OAMA_TILEID], TARGET_LOW_TILEID
    copy [SPRITE_7_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; PLAYER 'SHIELD' SPRITES
    copy [SPRITE_8_ADDRESS + OAMA_Y], 0
    copy [SPRITE_8_ADDRESS + OAMA_X], 0
    copy [SPRITE_8_ADDRESS + OAMA_TILEID], SHIELD_HIGH_TILEID
    copy [SPRITE_8_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_9_ADDRESS + OAMA_Y], 0
    copy [SPRITE_9_ADDRESS + OAMA_X], 0
    copy [SPRITE_9_ADDRESS + OAMA_TILEID], SHIELD_LOW_TILEID
    copy [SPRITE_9_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; SPELL OBJ SPRITES
    ;-- SPELL 1
    copy [SPRITE_10_ADDRESS + OAMA_Y], 0
    copy [SPRITE_10_ADDRESS + OAMA_X], 0
    copy [SPRITE_10_ADDRESS + OAMA_TILEID], SPELL1A_TILEID
    copy [SPRITE_10_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_11_ADDRESS + OAMA_Y], 0
    copy [SPRITE_11_ADDRESS + OAMA_X], 0
    copy [SPRITE_11_ADDRESS + OAMA_TILEID], SPELL1B_TILEID
    copy [SPRITE_11_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ;-- SPELL 2
    copy [SPRITE_12_ADDRESS + OAMA_Y], 0
    copy [SPRITE_12_ADDRESS + OAMA_X], 0
    copy [SPRITE_12_ADDRESS + OAMA_TILEID], SPELL1A_TILEID
    copy [SPRITE_12_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_13_ADDRESS + OAMA_Y], 0
    copy [SPRITE_13_ADDRESS + OAMA_X], 0
    copy [SPRITE_13_ADDRESS + OAMA_TILEID], SPELL1B_TILEID
    copy [SPRITE_13_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ;--SPELL 3
    copy [SPRITE_14_ADDRESS + OAMA_Y], 0
    copy [SPRITE_14_ADDRESS + OAMA_X], 0
    copy [SPRITE_14_ADDRESS + OAMA_TILEID], SPELL2A_TILEID
    copy [SPRITE_14_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_15_ADDRESS + OAMA_Y], 0
    copy [SPRITE_15_ADDRESS + OAMA_X], 0
    copy [SPRITE_15_ADDRESS + OAMA_TILEID], SPELL2B_TILEID
    copy [SPRITE_15_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ;--SPELL 4
    copy [SPRITE_16_ADDRESS + OAMA_Y], 0
    copy [SPRITE_16_ADDRESS + OAMA_X], 0
    copy [SPRITE_16_ADDRESS + OAMA_TILEID], SPELL2A_TILEID
    copy [SPRITE_16_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_17_ADDRESS + OAMA_Y], 0
    copy [SPRITE_17_ADDRESS + OAMA_X], 0
    copy [SPRITE_17_ADDRESS + OAMA_TILEID], SPELL2B_TILEID
    copy [SPRITE_17_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ret

move_sprites_to_start:
    ; TARGETS
    copy [SPRITE_6_ADDRESS + OAMA_Y], TARGET_HIGH_Y
    copy [SPRITE_6_ADDRESS + OAMA_X], TARGET_X

    copy [SPRITE_7_ADDRESS + OAMA_Y], TARGET_LOW_Y
    copy [SPRITE_7_ADDRESS + OAMA_X], TARGET_X

    ; SPELL 1
    copy [SPRITE_10_ADDRESS + OAMA_Y], SPELL_HIGH_Y
    copy [SPRITE_10_ADDRESS + OAMA_X], 0
    copy [SPRITE_11_ADDRESS + OAMA_Y], SPELL_HIGH_Y
    copy [SPRITE_11_ADDRESS + OAMA_X], 0

    ; SPELL 2
    copy [SPRITE_12_ADDRESS + OAMA_Y], SPELL_LOW_Y
    copy [SPRITE_10_ADDRESS + OAMA_X], 128
    copy [SPRITE_13_ADDRESS + OAMA_Y], SPELL_LOW_Y
    copy [SPRITE_11_ADDRESS + OAMA_X], 128

    ret

; note: refactor this to work thru WRAM
update_sprites:
    ; custom timing here:
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

        ld a, [hl]
        
        ; load in new x val
        sub SPELL_SCROLL_SPEED
        ld [hl], a

        add a, OBJ16_OFFSET

        ; load spell_b address into (hl)
        ld h, d
        ld l, e
        inc hl
        inc hl
        WRAMToOAM hl
        ld b, $00
        ld c, OAMA_X
        add hl, bc
        ld [hl], a

        ; to next spell sprite
        pop hl
        inc hl
        inc hl
        inc hl
        inc hl
        
        ld a, l
        cp a, $38; $40
        jr nz, .update_spell_sprite

    SetShieldLocations 0, 0, 0, 0

    call check_collisions
    .done_update
    ret

; TEST w/ 1 SPRITE --> mostly works -S
check_collisions:
    ; raise miss flag by default
    copy [rCOLLISION], COLLF_XMISS
    
    ; loop thru all sprites in wram
    ; ^ add that bit later

    
    ; check if the current x is within the 'perfect' x range
    ; set perf flag if so
    CheckSpriteRange [SPRITE_10_ADDRESS + OAMA_X]
    ; [SPRITE_10_ADDRESS + OAMA_X], HIT_PERF_MIN, HIT_PERF_MAX, rCOLLB_XPERF

    ld a, [PAD_CURR]
    bit PADB_A, a
    jr nz, .check_miss
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
    ld [SPRITE_10_ADDRESS + OAMA_X], a
    ld [SPRITE_11_ADDRESS + OAMA_X], a
    ; note: 2nd tile is visible when setting x = 0
    ;   could make a 'hide sprite' function?
    ; set 'inactive' flag?
    ret

handle_miss:
    ; will be called if no button is pressed
    ; note: change so x val comparison is outside func call?
    ; note: eventually flash the player sprite (damage)
    ld a, [SPRITE_10_ADDRESS + OAMA_X]
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

export init_sprite_data, init_sprites, update_sprites, move_sprites_to_start