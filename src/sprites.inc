; 
; CS-240 World 5: Basic Game Functionality
;
; @file sprites.inc
; @author Sydney Chen, Alfonso Rada
; @date April 7, 2025
; @brief storing all sprite constants and macros

if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; WRAM
def SPELL_FLAG_START equ ($C020)
def SPELL_FLAG_INTERVAL equ (2)
def SPELL_WRAM_START equ ($C030)
def SPELL_WRAM_END   equ ($C040)

; TARGETS
def SPRITE_6_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 6)
def SPRITE_7_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 7)

; PLAYER 'SHIELD'
def SPRITE_8_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 8)
def SPRITE_9_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 9)

; SPELL OBJS
def SPRITE_10_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 10)
def SPRITE_11_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 11)
def SPRITE_12_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 12)
def SPRITE_13_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 13)
def SPRITE_14_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 14)
def SPRITE_15_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 15)
def SPRITE_16_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 16)
def SPRITE_17_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 17)

def OBJ16_OFFSET           equ 8

def MC_TOP_Y equ (80)
def MC_BOT_Y equ (MC_TOP_Y + 16)
def MC_JUMP_THRES equ (MC_TOP_Y - 24)

def TARGET_HIGH_Y          equ (MC_TOP_Y - 16)
def TARGET_LOW_Y           equ (MC_TOP_Y + 16)
def TARGET_X               equ 50

def SPELL_HIGH_Y           equ (TARGET_HIGH_Y - 4)
def SPELL_LOW_Y            equ (TARGET_LOW_Y - 4)
def SPELL_SCROLL_SPEED     equ 4

def HIT_PERF_MIN           equ (50 - 8)
def HIT_PERF_MAX           equ (HIT_PERF_MIN + 16)
def HIT_MISS_MAX           equ (HIT_PERF_MIN - 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; PLAYER MACROS ;;;

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

        ; store sprite address in hl
        ld b, [hl]
        inc hl
        ld c, [hl]
        ld h, b
        ld l, c

        ; get sprite's tileID address
        ld a, l
        add a, OAMA_TILEID
        ld l, a
        ld a, [hl] 

        ; change tileID as appropriate
        cp a, \3
        jr c, .load_new_tileid
            sub a, \3
            jr .finish_tile_load

        .load_new_tileid
            add a, $10

        .finish_tile_load
        ld [hl], a

        ; go to next tile in WRAM
        pop hl
        inc hl
        inc hl
    
        ; check if last sprite was reached in WRAM
        ld a, l
        cp a, low(\2)
        jr nz, .next_tile

    .end_update
    pop hl
    pop bc
    pop af
endm

; set an input's associated animation flags/registers/tileIDs
macro ProcessInputForAnim
    ld a, [PAD_CURR]
    bit \1, a
    jr nz, .done_process\@
        RegBitOp rPLAYER, \2, set
        copy [rPC_ACOUNT], $00 
        SetPlayerTiles \3
    .done_process\@
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
    add a, $10
    ld [SPRITE_3_ADDRESS + \2], a
    ld [SPRITE_4_ADDRESS + \2], a
    ld [SPRITE_5_ADDRESS + \2], a
    sub a, $10
endm

;;; SPRITE MACROS ;;;

; set 'shield' sprite locations in form (x1, y1), (x2, y2)
macro SetShieldLocations
    copy [SPRITE_8_ADDRESS + OAMA_X], \1
    copy [SPRITE_8_ADDRESS + OAMA_Y], \2
    
    copy [SPRITE_9_ADDRESS + OAMA_X], \3
    copy [SPRITE_9_ADDRESS + OAMA_Y], \4
endm

; checks if a given sprite's x val is within a given range
; params:
;   curr_x, range_min, range_max, flag_bit, flag_binary
; NOTE: currently hard-coded to a perfect hit
macro CheckSpriteRange
    ld a, \1
    cp HIT_PERF_MIN
        ; fail if less than min
        jr c, .done_check\@
        cp HIT_PERF_MAX
            ; fail if greater than max
            jr nc, .check_miss\@
                RegBitOp rCOLLISION, COLLB_XPERF, set
                jr .done_check\@ ; keep bc faster?
    
    .check_miss\@
        cp HIT_MISS_MAX
        jr c, .done_check\@
            RegBitOp rCOLLISION, COLLB_XMISS, res
    
    .done_check\@
endm

macro WRAMToOAM
    ;ld hl, \1

    ; store sprite address in hl
    ld b, [\1]
    inc hl
    ld c, [\1]
    ld h, b
    ld l, c
endm

macro SpawnSpell
    ; (hl) = sprite address
    ; (de) = spell flags
    ; spell y = high or low (see flag)
    ; spell x = 0
endm

macro SetSpriteXY
    copy [(_OAMRAM + sizeof_OAM_ATTRS * \1) + OAMA_X], \2
    copy [(_OAMRAM + sizeof_OAM_ATTRS * \1) + OAMA_Y], \3
endm

macro SetSpriteData
    SetSpriteXY \1, \2, \3
    copy [(_OAMRAM + sizeof_OAM_ATTRS * \1) + OAMA_TILEID], \4
    copy [(_OAMRAM + sizeof_OAM_ATTRS * \1) + OAMA_FLAGS], \5
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc