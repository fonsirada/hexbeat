
; ADD HEADER

;;;


;;;; SPRITE MACROS
macro UpdateRunAnim
    push af
    push bc
    push hl

    ; loop thru wram address locations
    ld hl, $C010 ; or, PC_SPRITE_1_LOC

    .next_tile
    push hl

    ; store _OAMRAM in hl
    ld b, [hl]
    inc hl
    ld c, [hl]
    ld h, b
    ld l, c

    ; ld a, [hl] ; now @ sprite address
    ;add hl, OAMA_TILEID ; get tileid address
    ld a, l
    add a, OAMA_TILEID
    ld l, a

    ;ld b, a

    ld a, [hl] ; get tile ID in (a)

    cp a, $30 ; check if last frame was reached --> may be $50?
    jr c, .load_new_tileid
        sub a, $30
        ; load (starting tile ID - 10) ==> (a)
        jr .post_add
    .load_new_tileid
    add a, $10 ; go to next frame
    .post_add
    ld [hl], a

    ;; now going to next sprite...
    pop hl
    inc hl
    inc hl
    
    ; cp hl, $C016 ; number of obj16 tiles in sprite ;repl w/ PC_SPRITE_6_LOC or smth
    ld a, l
    cp a, $1C
    jr nz, .next_tile

    pop hl
    pop bc
    pop af
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

