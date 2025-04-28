; 
; CS-240 World 7: Feature complete game
;
; @file sprites.inc
; @author Sydney Chen, Alfonso Rada
; @date April 24, 2025
; @brief storing all sprite constants and macros

if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
def SPRITE_18_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 18)
def SPRITE_19_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 19)
def SPRITE_20_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 20)
def SPRITE_21_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 21)
def SPRITE_22_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 22)
def SPRITE_23_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 23)
def SPRITE_24_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 24)
def SPRITE_25_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 25)

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

        ;; LOAD TILE ID ;;
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
            add a, MC_VRAM_ANIM_INT

        .finish_tile_load
        ld [hli], a ; replace w/ hli & remove below line

        ;; FLASH PALETTE ;;
        ld a, [rTIMER_DMG]
        cp a, 0
        jr z, .no_flash
            cp a, (PC_DMG_COUNT + 1)
            jr nc, .no_flash
                dec a
                ld [rTIMER_DMG], a

                ld a, [hl]
                xor a, OAMF_PAL1
                ld [hl], a
                jr .done_flash
        .no_flash
            ld a, [hl]
            and a, OAMF_PAL0
            ld [hl], a
        .done_flash

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
    add a, MC_VRAM_ANIM_INT
    ld [SPRITE_3_ADDRESS + \2], a
    ld [SPRITE_4_ADDRESS + \2], a
    ld [SPRITE_5_ADDRESS + \2], a
    sub a, MC_VRAM_ANIM_INT
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc