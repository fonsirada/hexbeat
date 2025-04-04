; header here

include "src/joypad.inc"
include "src/hardware.inc"
include "src/utils.inc"


section "joypad", rom0

; update_joypad:
;     halt

;     ; get the joypad buttons that are being held!
;     ld a, [PAD_CURR]

;     ; Is 'a' being held?
;     bit PADB_A, a
;     jr nz, .done_pressing_a
;     ; perform action
;         ; jump

;         ;ld a, [$C000]
;         ;inc a
;         ;inc a
;         ;ld [$C000], a
;         ;copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0
;     .done_pressing_a

;     ret

; export update_joypad