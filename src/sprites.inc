; 
; CS-240 World 5: Basic Game Functionality
;
; @file sprites.inc
; @author Sydney Chen, Alfonso Rada
; @brief storing all sprite constants and macros

;; CONSTs

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

; 'SHIELD' SPRITES
def SPRITE_8_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 8)
def SPRITE_9_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 9)

; SPELL OBJS
def SPRITE_10_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 10)
def SPRITE_11_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 11)
def SPRITE_12_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 12)
def SPRITE_13_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS * 13)

def MC_TOP_Y equ (80)
def MC_BOT_Y equ (MC_TOP_Y + 16)
def MC_JUMP_THRES equ (MC_TOP_Y - 16)


;;;; SPRITE MACROS

;;; -> PLAYER
; w/ run: UpdatePlayerAnim $C010, $C01C, $30
macro UpdatePlayerAnim
    push af
    push bc
    push hl

    ; starting address
    ld hl, \1 ; $C010 ; or, PC_SPRITE_1_LOC

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

    ; HOLD IS BROKEN; FIGURE OUT WHY.
    ; hold a frame --> move to start?
    /*
    ld a, [rGAME]
    bit 6, a
    jr nz, .skip_hold
        ; end update and reset hold flag
        ; ld a, [rGAME]
        xor GAME_HOLDANIM
        ld [rGAME], a

        jr .end_update
    .skip_hold

    ; load tile ID into (a)
    ld a, [hl] 

    ; check if raising hold flag
    ; cp first tileID w/ given tile ID, if equal, set flag
    ; if no hold desired, set arbitrarily high 4th param
    cp a, \4
    jr nz, .done_hold_check
        ld a, [rGAME] ; make this a macro
        xor GAME_HOLDANIM
        ld [rGAME], a
    .done_hold_check
    */
    ; ld a, \4

    ld a, [hl] 

    ; check if last frame was reached
    cp a, \3 ; $30 
    jr c, .load_new_tileid
        ; reset to first frame
        sub a, \3 ; $30 ; M#: "run anim frames" ?
        jr .finish_load
    .load_new_tileid
        ; go to next frame
        add a, $10 ; M#: "frame gap"
    .finish_load
    ld [hl], a

    ; now going to next sprite...
    pop hl
    inc hl
    inc hl
    
    ; check if last sprite was reached in WRAM
    ; number of obj16 tiles in sprite ;repl w/ PC_SPRITE_6_LOC or smth
    ld a, l
    cp a, low(\2); $1C 
    jr nz, .next_tile

    .end_update
    pop hl
    pop bc
    pop af
endm

macro SetPlayerTiles
   copy [SPRITE_0_ADDRESS + OAMA_TILEID], \1
   copy [SPRITE_1_ADDRESS + OAMA_TILEID], \1 + 2
   copy [SPRITE_2_ADDRESS + OAMA_TILEID], \1 + 4
   copy [SPRITE_3_ADDRESS + OAMA_TILEID], \1 + 6
   copy [SPRITE_4_ADDRESS + OAMA_TILEID], \1 + 8
   copy [SPRITE_5_ADDRESS + OAMA_TILEID], \1 + 10

   endm

macro SetPlayerY
    ld a, \1
    ld [SPRITE_0_ADDRESS + OAMA_Y], a
    ld [SPRITE_1_ADDRESS + OAMA_Y], a
    ld [SPRITE_2_ADDRESS + OAMA_Y], a
    add a, $10
    ld [SPRITE_3_ADDRESS + OAMA_Y], a
    ld [SPRITE_4_ADDRESS + OAMA_Y], a
    ld [SPRITE_5_ADDRESS + OAMA_Y], a
endm





; move 8x16 sprite down
; *how to make the "sprite 0 address" bit modular?
macro Move8x16Down
    push bc
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    ld b, a
    inc b
    copy [SPRITE_0_ADDRESS + OAMA_Y], b

    ld a, b
    add a, 8
    ld b, a
    copy [SPRITE_1_ADDRESS + OAMA_Y], b
    pop bc
endm

macro Move24x32Down
    Move8x16Down ;
    Move8x16Down ;
    Move8x16Down ;
endm

; move 8x16 sprite right
macro Move8x16Right
    push bc
    ld a, [SPRITE_0_ADDRESS + OAMA_X]
    ld b, a
    inc b
    copy [SPRITE_0_ADDRESS + OAMA_X], b
    copy [SPRITE_1_ADDRESS + OAMA_X], b
    pop bc
endm

