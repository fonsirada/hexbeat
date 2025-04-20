; header

include "src/hardware.inc"
include "src/joypad.inc"
include "src/sprites.inc"
include "src/utils.inc"


section "sound", rom0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rsset (_RAM + $30) ; change this location at some point

def WRAM_PAD_INPUT                  rb 0 ;sizeof_PAD_INPUT
def WRAM_FRAME_COUNTER              rb 1
def WRAM_NOTE_INDEX                 rb 1

def WRAM_END                        rb 0

; sanity checks
def WRAM_USAGE                      equ (WRAM_END - _RAM)
println "WRAM usage: {d:WRAM_USAGE} bytes"
assert WRAM_USAGE <= $2000, "Too many bytes used in WRAM"

; ROM usage
def TIME_BETWEEN_NOTES          equ (20)

Notes:
dw $060b, $0642, $0672, $0689, $06b2, $06d6, $06f7, $0706
dw $06f7, $06d6, $06b2, $0689, $0672, $0642, $060b, $0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; functions
init_sound:
    ; init the WRAM state
    ;InitPadInput WRAM_PAD_INPUT
    ;InitJoypad WRAM_PAD_INPUT
    copy [WRAM_FRAME_COUNTER], 0; $FF
    xor a
    ld [WRAM_NOTE_INDEX], a

    ; init the sound
    copy [rNR52], AUDENA_ON
    copy [rNR50], $77
    copy [rNR51], $FF

    ret

UpdateSample:
    halt

    ;UpdatePadInput WRAM_PAD_INPUT
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
            ld a, [WRAM_NOTE_INDEX]
            inc a
            ld [WRAM_NOTE_INDEX], a

            sla a
            ld d, 0
            ld e, a

            ld hl, Notes
            add hl, de

            ld a, [hli]
            or a, a
            jr nz, .stop_sound
                copy [rNR12], $00
                copy [rNR14], $C0
                ld a, $FF
                ld [WRAM_FRAME_COUNTER], a
                jr .play_notes
            .stop_sound

            ld [rNR13], a
            ld a, [hli]
            ld [rNR14], a

            copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
        .sound_switch

    .play_notes

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;TestPadInput_Pressed WRAM_PAD_INPUT, PADF_A
    ;ld a, [WRAM_PAD_INPUT + PAD_INPUT_PRESSED]
    ;bit PADB_A, a
    ld a, [PAD_CURR]
    bit PADB_A, a
    jr nz, .start_notes
        xor a
        ld [WRAM_NOTE_INDEX], a

        copy [rNR10], $00
        copy [rNR11], $80
        copy [rNR12], $F0

        ld hl, Notes
        ld a, [hli]
        ld [rNR13], a
        ld a, [hl]
        or a, $80
        ld [rNR14], a

        copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
    .start_notes

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sound, UpdateSample