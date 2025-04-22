; header

include "src/hardware.inc"
include "src/joypad.inc"
include "src/sprites.inc"
include "src/utils.inc"


section "sound", rom0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rsset (_RAM + $40) ; change this location at some point

def WRAM_PAD_INPUT                  rb 0 ;sizeof_PAD_INPUT
def WRAM_FRAME_COUNTER              rb 1
def WRAM_NOTE_INDEX                 rb 1

def WRAM_END                        rb 0

; sanity checks
def WRAM_USAGE                      equ (WRAM_END - _RAM)
println "WRAM usage: {d:WRAM_USAGE} bytes"
assert WRAM_USAGE <= $2000, "Too many bytes used in WRAM"

; ROM usage
def TIME_BETWEEN_NOTES          equ 10;(20)

Notes:
;continuous notes
;dw $060b, $0642, $0672, $0689, $06b2, $06d6, $06f7, $0706
;dw $06f7, $06d6, $06b2, $0689, $0672, $0642, $060b, $0000
dw $89c6, $89c6, $89c6, $89c6, $89c6, $89c6, $89c6, $89c6
dw $89c6, $b2c6, $c4c6, $c4c6, $89c6, $b2c6, $c4c6, $b2c6
dw $89c6, $b2c6, $c4c6, $c4c6, $89c6, $b2c6, $c4c6, $b2c6
dw $0000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; functions
init_sound:
    ; init the WRAM state
    ;InitJoypad WRAM_PAD_INPUT
    copy [WRAM_FRAME_COUNTER], 0; $FF ;$FF to disable
    xor a
    ld [WRAM_NOTE_INDEX], a

    ; init the sound
    copy [rNR52], AUDENA_ON

    ; high nibble = left speaker vol
    ; low nibble = right speaker vol
    copy [rNR50], $77
    
    copy [rNR51], $FF
    ; use sound mixing settings to inc difficulty?

    ret

UpdateSample:
    halt

    UpdateJoypad WRAM_PAD_INPUT
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; skip counter check if the counter is disabled (equals $FF)
    ld a, $FF
    ld hl, WRAM_FRAME_COUNTER
    xor a, [hl]
    jr z, .play_notes

        ; decrease the timer and play the next sound when zero is reached
        dec [hl]
        jr nz, .sound_switch
            ; increase note index
            ld a, [WRAM_NOTE_INDEX]
            inc a
            ld [WRAM_NOTE_INDEX], a

            sla a ; sla increases by 4?
            ld d, 0
            ld e, a

            ; load note + note index
            ld hl, Notes
            add hl, de

            ; get note; if note is 0, stop sound
            ld a, [hli]
            or a, a
            jr nz, .stop_sound
                ;copy [rNR12], $00
                ;copy [rNR14], $C0
                copy [rNR22], $00
                copy [rNR24], $C0
                ld a, $FF
                ld [WRAM_FRAME_COUNTER], a
                jr .play_notes
            .stop_sound

            ;ld [rNR13], a
            ;ld a, [hli]
            ;ld [rNR14], a
            ld [rNR23], a
            ld a, [hli]
            ld [rNR24], a

            copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
        .sound_switch

    .play_notes

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; start playing notes when start is pressed
    ld a, [PAD_CURR]
    bit PADB_START, a
    jr nz, .start_notes
        xor a
        ld [WRAM_NOTE_INDEX], a

        /*
        copy [rNR10], $00
        copy [rNR11], $80
        copy [rNR12], $F0
        */

        ; high nibble = duty (0, 4, 8, C)
        ; low nibble = length (00-3F)
        copy [rNR21], $80 

        ; high nibble = volume (0-F)
        ; low nibble = envelope (down, 0-7; up, 8-F)
        copy [rNR22], $F0

        ; init first note & start sound
        ld hl, Notes
        ld a, [hli]
        ld [rNR23], a
        ld a, [hl]
        or a, $80
        ld [rNR24], a

        copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
    .start_notes

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sound, UpdateSample