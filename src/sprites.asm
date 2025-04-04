; header here

include "src/hardware.inc"

;; CONST
def SPRITE_0_ADDRESS equ (_OAMRAM)
def SPRITE_1_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS)

;; MACROS
; copy \2 into \1 through (a)
; example: copy [$FF84], 10
macro copy
    ld a, \2
    ld \1, a
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


/*
;; FUNCTIONS

; 



;;;;;;;;;;;;;;
; initialize sprites? (figure out how to organize this)

; INIT SPRITES
    ; set sprite 1.1
    copy [SPRITE_0_ADDRESS + OAMA_X], 
    copy [SPRITE_0_ADDRESS + OAMA_Y],  ; 80 to overlap
    copy [SPRITE_0_ADDRESS + OAMA_TILEID], 0
    copy [SPRITE_0_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; set sprite 1.2
    copy [SPRITE_1_ADDRESS + OAMA_X], 
    copy [SPRITE_1_ADDRESS + OAMA_Y],  ; 80 to overlap
    copy [SPRITE_1_ADDRESS + OAMA_TILEID], 2
    copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; set sprite 1.3
    copy [SPRITE_2_ADDRESS + OAMA_X], 
    copy [SPRITE_2_ADDRESS + OAMA_Y],  ; 80 to overlap
    copy [SPRITE_2_ADDRESS + OAMA_TILEID], 2
    copy [SPRITE_2_ADDRESS + OAMA_FLAGS], OAMF_PAL0

*/
