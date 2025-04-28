; 
; CS-240 World 8: Your final, polished game
;
; @file sprites.asm
; @author Sydney Chen, Alfonso Rada
; @date April 24, 2025
; @brief storing non-player sprite functions

include "src/hardware.inc"
include "src/joypad.inc"
include "src/sprites.inc"
include "src/utils.inc"

section "sound", rom0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def TIME_BETWEEN_NOTES          equ (10)

Ch1_Notes:
;continuous example notes (scale)
dw $060b, $0642, $0672, $0689, $06b2, $06d6, $06f7, $0706

; add additional byte for "length between notes" val
Ch2_Notes:
dw $c689, $c6b2, $c6c4, $c6c4, $c689, $c6b2, $c6c4, $c6b2
dw $8689, $86b2, $86c4, $86c4, $8689, $86b2, $86c4, $86b2
dw $0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_sound:
    copy [WRAM_FRAME_COUNTER], 0
    xor a
    ld [WRAM_NOTE_INDEX], a

    copy [rNR52], AUDENA_ON

    ; high nibble = left speaker vol, low nibble = right speaker vol
    copy [rNR50], $77
    copy [rNR51], $FF

    ret

update_music:
    ld a, $FF
    ld hl, WRAM_FRAME_COUNTER
    xor a, [hl]
    jr z, .play_notes
        ; decrease the timer and play the next sound when zero is reached
        dec [hl]
        jr nz, .play_notes
            ld a, [WRAM_NOTE_INDEX]
            inc a
            ld [WRAM_NOTE_INDEX], a
    
            sla a
            ld d, 0
            ld e, a
    
            ; load note + note index
            ld hl, Ch2_Notes
            add hl, de
    
            ; get note - if note is 0, stop sound
            ld a, [hli]
            or a, a
            jr nz, .stop_sound
                xor a
                ld [WRAM_NOTE_INDEX], a
            
            .stop_sound
            ld [rNR23], a
            ld a, [hli]
            ld [rNR24], a

            copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES

    .play_notes
    ld a, [rGAME]
    bit GAMEB_START, a
    jr z, .started_notes
        ld a, [PAD_CURR]
        bit PADB_START, a
        jr nz, .started_notes
            copy [rNR21], $80 
            copy [rNR22], $F6

            ; init first note & start sound
            ld hl, Ch2_Notes
            ld a, [hli]
            ld [rNR23], a
            ld a, [hl]
            or a, $80
            ld [rNR24], a

            copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES

    .started_notes
    ret

update_sound:
    call update_music
    ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sound, update_sound