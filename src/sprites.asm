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
    copy [SPRITE_12_ADDRESS + OAMA_TILEID], SPELL2A_TILEID
    copy [SPRITE_12_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    copy [SPRITE_13_ADDRESS + OAMA_Y], 0
    copy [SPRITE_13_ADDRESS + OAMA_X], 0
    copy [SPRITE_13_ADDRESS + OAMA_TILEID], SPELL2B_TILEID
    copy [SPRITE_13_ADDRESS + OAMA_FLAGS], OAMF_PAL0

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

    ret

update_sprites:
    ; custom timing here:
    CheckTimer rTIMER_OBJ, 1
    jr nz, .done_update

    ; scrolling spell 1
    ld a, [SPRITE_10_ADDRESS + OAMA_X]
    sub SPELL_SCROLL_SPEED
    ld [SPRITE_10_ADDRESS + OAMA_X], a
    add OBJ16_OFFSET
    ld [SPRITE_11_ADDRESS + OAMA_X], a

    SetShieldLocations 0, 0, 0, 0

    call check_collisions
    .done_update
    ret

check_collisions:
    ; load miss flag into rCOLLISION
    copy [rCOLLISION], COLLF_XMISS
    
    ; loop thru all sprites in wram
    ; ^ add that bit later

    ; TEST w/ 1 SPRITE --> mostly works -S
    
    ; check if the current x is within the 'perfect' x range
    ; set perf fleg if so
    ; *inconsistent flag raising? -S
    ld a, [SPRITE_10_ADDRESS + OAMA_X]
    CheckSpriteRange a ; HIT_PERF_MIN, HIT_PERF_MAX, rCOLLB_XPERF

    ld a, [rCOLLISION]
    bit COLLB_XPERF, a
    jr z, .done_check
        ld a, [PAD_CURR]
        bit PADB_A, a
        jr nz, .done_check
            call handle_collision
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sprite_data, init_sprites, update_sprites, move_sprites_to_start