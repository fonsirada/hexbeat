; header here

include "joypad.inc"


UpdateSample:
    halt

    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is 'a' being held?
    bit PADB_A, a
    jr nz, .done_pressing_a
    ; perform action
        ; jump
        ld a, [SPRITE_1_ADDRESS + OAMA_X]
        inc a
        ld [SPRITE_1_ADDRESS + OAMA_X], a
        copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0
    .done_pressing_a

    ret