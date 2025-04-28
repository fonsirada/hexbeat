; 
; CS-240 World 8: Your final, polished game
;
; @file sprites.inc
; @author Sydney Chen, Alfonso Rada
; @date April 24, 2025
; @brief storing all sprite constants and macros

if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PLAYER SPRITES
rsset _OAMRAM
def SPRITE_0_ADDRESS                rb sizeof_OAM_ATTRS
def SPRITE_1_ADDRESS                rb sizeof_OAM_ATTRS
def SPRITE_2_ADDRESS                rb sizeof_OAM_ATTRS
def SPRITE_3_ADDRESS                rb sizeof_OAM_ATTRS
def SPRITE_4_ADDRESS                rb sizeof_OAM_ATTRS
def SPRITE_5_ADDRESS                rb sizeof_OAM_ATTRS

; TARGETS
def SPRITE_6_ADDRESS                rb sizeof_OAM_ATTRS
def SPRITE_7_ADDRESS                rb sizeof_OAM_ATTRS

; PLAYER 'SHIELD'
def SPRITE_8_ADDRESS                rb sizeof_OAM_ATTRS
def SPRITE_9_ADDRESS                rb sizeof_OAM_ATTRS

; SPELL OBJS
def SPRITE_10_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_11_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_12_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_13_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_14_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_15_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_16_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_17_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_18_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_19_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_20_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_21_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_22_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_23_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_24_ADDRESS               rb sizeof_OAM_ATTRS
def SPRITE_25_ADDRESS               rb sizeof_OAM_ATTRS

def OBJ16_OFFSET           equ 8

def MC_TOP_Y               equ (80)
def MC_BOT_Y               equ (MC_TOP_Y + 16)
def MC_JUMP_THRES          equ (MC_TOP_Y - 24)
def MC_VRAM_ANIM_INT       equ $10

def TARGET_HIGH_Y          equ (MC_TOP_Y - 16)
def TARGET_LOW_Y           equ (MC_TOP_Y + 16)
def TARGET_X               equ 50

def SPELL_HIGH_Y           equ (TARGET_HIGH_Y - 4)
def SPELL_LOW_Y            equ (TARGET_LOW_Y - 4)
def SPELL_SCROLL_SPEED     equ 3
def SPELL_SPAWNX           equ 168

; TIMING
def HIT_PERF_MIN           equ (TARGET_X - 4)
def HIT_PERF_MAX           equ (TARGET_X + 8 + 4)
def HIT_GOOD_MIN           equ (TARGET_X - 12)
def HIT_GOOD_MAX           equ (TARGET_X + 8 + 8)
def HIT_BAD_MIN            equ (TARGET_X - 20)
def HIT_BAD_MAX            equ (TARGET_X + 8 + 20)
def HIT_MISS_MAX           equ (HIT_BAD_MIN - 1)
def HIT_MISS_MIN           equ (0)
def DMG_THRES              equ (4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; given an address in WRAM from (hl), get the OAM address there
; and store in (hl)
; NEW: store the address at (hl) in a given 16bit register
macro WRAMToOAM
    ld high(\1), [hl]
    inc hl
    ld low(\1), [hl]
    ld h, high(\1)
    ld l, low(\1)
endm

; params: sprite number, x val, y val
macro SetSpriteXY
    copy [(_OAMRAM + sizeof_OAM_ATTRS * \1) + OAMA_X], \2
    copy [(_OAMRAM + sizeof_OAM_ATTRS * \1) + OAMA_Y], \3
endm

; params: sprite number, x val, y val, tile ID, flags
macro SetSpriteData
    SetSpriteXY \1, \2, \3
    copy [(_OAMRAM + sizeof_OAM_ATTRS * \1) + OAMA_TILEID], \4
    copy [(_OAMRAM + sizeof_OAM_ATTRS * \1) + OAMA_FLAGS], \5
endm


;;; SPELL MACROS ;;;

; checks if a given sprite's x val is within a given range
; params:
;   curr_x, range_min, range_max, flag_bit
; ex: CheckSpriteRange [hl], HIT_PERF_MIN, HIT_PERF_MAX, rCOLLB_XPERF
macro CheckSpriteRange
    ld a, \1
    cp \2
        ; don't set if less than min
        jr c, .done_check\@
        cp \3
            ; don't set if greater than max
            jr nc, .done_check\@
                ld a, [rCOLLISION]
                set \4, a
                ld [rCOLLISION], a
    .done_check\@
endm

; store the flags of spell sprite @ (hl) in a given reg
macro GetSpriteFlags
    push hl
            
    ; do (hl) - $10
    ld a, l
    sub a, SPELLF_WRAM_OFFSET
    ld l, a

    ld \1, [hl]
    pop hl
endm

; set a spell sprite's flags
macro SetSpriteFlags
    push hl
            
    ; do (hl) - $10
    ld a, l
    sub a, SPELLF_WRAM_OFFSET
    ld l, a

    ld [hl], \1
    pop hl
endm


; given sprite address (hl) and flags as param (in d)
; spawns a spell according to its tier flag
; note: spell's pt 2 will update in main func
macro SpawnSpell 
    ld a, \1
    bit SPELLB_TIER, a
    jr z, .set_low\@
        ld [hl], SPELL_HIGH_Y
        jr .set_x\@
    .set_low\@
        ld [hl], SPELL_LOW_Y
    .set_x\@
    inc hl
    ld [hl], SPELL_SPAWNX
    dec hl
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc