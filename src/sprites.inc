; 
; CS-240 World 5: Basic Game Functionality
;
; @file sprites.inc
; @author Sydney Chen, Alfonso Rada
; @brief storing all sprite constants and macros

if !def(SPRITES_RGBINC)
def SPRITES_RGBINC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PLAYER
def SPRITE_0_ADDRESS equ (_OAMRAM)
def SPRITE_1_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS)
def SPRITE_2_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 2)
def SPRITE_3_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 3)
def SPRITE_4_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 4)
def SPRITE_5_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 5)

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

def MC_TOP_Y equ (80)
def MC_BOT_Y equ (MC_TOP_Y + 16)
def MC_JUMP_THRES equ (MC_TOP_Y - 24)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; PLAYER MACROS

; updates the Player sprite(s) to the next frame
; by looping thru sprite locations stored in WRAM
; run as: UpdatePlayerAnim (WRAM start address, WRAM end address, ending tileID)
; ex: UpdatePlayerAnim $C010, $C01C, $30
macro UpdatePlayerAnim
    push af
    push bc
    push hl

    ; starting address
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

    ; get sprite's tileid address
    ld a, l
    add a, OAMA_TILEID
    ld l, a
    ld a, [hl] 

    ; check if last frame was reached
    cp a, \3
    jr c, .load_new_tileid
        ; reset to first frame
        sub a, \3
        jr .finish_load

    .load_new_tileid
        add a, $10

    .finish_load
    ld [hl], a

    ; now going to next sprite in WRAM...
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

; set the Player sprite(s)'s tileIDs based on the first sprite
macro SetPlayerTiles
   copy [SPRITE_0_ADDRESS + OAMA_TILEID], \1
   copy [SPRITE_1_ADDRESS + OAMA_TILEID], \1 + 2
   copy [SPRITE_2_ADDRESS + OAMA_TILEID], \1 + 4
   copy [SPRITE_3_ADDRESS + OAMA_TILEID], \1 + 6
   copy [SPRITE_4_ADDRESS + OAMA_TILEID], \1 + 8
   copy [SPRITE_5_ADDRESS + OAMA_TILEID], \1 + 10

endm

macro SetShieldLocations
    ; reset shield loc
    copy [SPRITE_8_ADDRESS + OAMA_Y], \1
    copy [SPRITE_8_ADDRESS + OAMA_X], \2
    
    ; reset shield loc
    copy [SPRITE_9_ADDRESS + OAMA_Y], \3
    copy [SPRITE_9_ADDRESS + OAMA_X], \4
endm

; set the Player sprite(s)'s Y value based on the first sprite
macro SetPlayerY
    ld a, \1
    ld [SPRITE_0_ADDRESS + OAMA_Y], a
    ld [SPRITE_1_ADDRESS + OAMA_Y], a
    ld [SPRITE_2_ADDRESS + OAMA_Y], a
    add a, $10
    ld [SPRITE_3_ADDRESS + OAMA_Y], a
    ld [SPRITE_4_ADDRESS + OAMA_Y], a
    ld [SPRITE_5_ADDRESS + OAMA_Y], a
    sub a, $10
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc