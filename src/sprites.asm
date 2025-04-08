; 
; CS-240 World 5: Basic Game Functionality
;
; @file sprites.asm
; @author Sydney Chen, Alfonso Rada
; @brief storing non-player sprite functions

include "src/hardware.inc"
include "src/utils.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "sprites", rom0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def OBJ16_OFFSET           equ 8
def MC_TOP_Y               equ $80

def TARGET_HIGH_TILEID     equ $4E
def TARGET_LOW_TILEID      equ $5E
def SHIELD_HIGH_TILEID     equ $6E
def SHIELD_LOW_TILEID      equ $7E
def SPELL1A_TILEID         equ $0E
def SPELL1B_TILEID         equ $1E
def SPELL2A_TILEID         equ $2E
def SPELL2B_TILEID         equ $3E

def TARGET_HIGH_Y          equ (MC_TOP_Y - 16)
def TARGET_LOW_Y           equ (MC_TOP_Y + 16)
def TARGET_X               equ 50

def SPELL_HIGH_Y           equ (MC_TOP_Y - 20)
def SPELL_SCROLL_SPEED     equ 4

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
    ; scrolling spell 1
    ld a, [SPRITE_10_ADDRESS + OAMA_X]
    sub SPELL_SCROLL_SPEED
    ld [SPRITE_10_ADDRESS + OAMA_X], a
    add OBJ16_OFFSET
    ld [SPRITE_11_ADDRESS + OAMA_X], a

    SetShieldLocations 0, 0, 0, 0

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sprite_data, init_sprites, update_sprites, move_sprites_to_start