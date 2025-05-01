; 
; CS-240 World 8: Your final, polished game
;
; @file sprites.asm
; @author Sydney Chen, Alfonso Rada
; @date April 24, 2025
; @brief storing non-player sprite functions
; @license

include "src/hardware.inc"
include "src/joypad.inc"
include "src/sprites.inc"
include "src/utils.inc"

section "sound", rom0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def TIME_BETWEEN_NOTES          equ (10)

CH1_NOTES:
;continuous example notes (scale)
dw $060b, $0642, $0672, $0689, $06b2, $06d6, $06f7, $0706

; add additional byte for "length between notes" val
CH2_NOTES_LVL1:
dw $8773, $874f, $8744, $874f, $8744, $8721, $8714, $8714,
dw $8721, $8714, $8721, $8714, $86e7, $86d6,
dw $c689, $c6b2, $c6c4, $c6c4, $c689, $c6b2, $c6c4, $c6b2
dw $8689, $86b2, $86c4, $86c4, $8689, $86b2, $86c4, $86b2

dw $0000

CH2_NOTES_LENGTHS_LVL1:
dw $0010, $0008, $0010, $0008, $0010, $0010, $0010, $0008, 
dw $0008, $0008, $0008, $0008, $0008, $0008,

dw $0008, $0008, $0008, $0008, $0008, $0008, $0008, $0008
dw $0008, $0008, $0008, $0008, $0008, $0008, $0008, $0008
dw $0001
; see commented out code below!

CH2_NOTES_LVL3:
dw $8762, $878a, $8762, $877b, $878a, $877b, $8762, $8762,  
dw $874f, $8762, $874f, $8739, $874f, $8762, $874f, $c74f, 
dw $c74f, $874f, $8762, $878a, $878a, $879d, $87a7, $879d, 
dw $8797, $8762, $878a, $878a, $8797, $8783, $878a, $8797,

dw $8797, $878a, $8773, $8773, $8762, $872d, $8714, $8721, 
dw $8744, $874f, $8744, $874f, $8744, $874f, $872d, $872d, 
dw $874f, $8762, $8773, $8783, $878a, $8797, $8773, $8773, 
dw $8783, $878a, $8797, $8783, $878a, $8797, $8773, 
dw $0000

CH2_NOTES_LENGTHS_LVL3:
dw $0018, $0020, $0006, $0008, $0008, $0008, $0018, $0010, 
dw $0010, $0008, $0008, $0008, $0010, $0020, $0008, $0008, 
dw $0008, $0008, $0010, $0018, $0010, $0010, $0008, $0008,  
dw $0008, $0010, $0030, $0018, $0010, $0010, $0010, $0018, 

dw $0008, $0008, $0018, $0008, $0008, $0018, $0010, $0010, 
dw $0008, $0008, $0008, $0008, $0008, $0008, $0010, $0008, 
dw $0008, $0010, $0008, $0008, $0008, $0010, $0020, $0008, 
dw $0008, $0008, $0010, $0010, $0008, $0008, $0008, 
dw $0001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_sound:
    ld a, high(CH2_NOTES_LVL3)
    ld [rSONGMAP], a
    ld a, low(CH2_NOTES_LVL3)
    ld [rSONGMAP + 1], a

    ld a, high(CH2_NOTES_LENGTHS_LVL3)
    ld [rSONGMAP_LENGTHS], a
    ld a, low(CH2_NOTES_LENGTHS_LVL3)
    ld [rSONGMAP_LENGTHS + 1], a

    copy [WRAM_FRAME_COUNTER], 0
    xor a
    ld [WRAM_NOTE_INDEX], a

    copy [rNR52], AUDENA_ON

    ; high nibble = left speaker vol, low nibble = right speaker vol
    copy [rNR50], $77
    copy [rNR51], $FF

    ret

; hmm... test sound func w/ ch 1?
play_hit_effect:

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
            ld a, [rSONGMAP]
            ld h, a
            ld a, [rSONGMAP + 1]
            ld l, a
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

            ; copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
            ; push/pop may not be needed
            ; push hl
            ;ld hl, CH2_NOTES_LENGTHS
            ld a, [rSONGMAP_LENGTHS]
            ld h, a
            ld a, [rSONGMAP_LENGTHS + 1]
            ld l, a
            add hl, de
            ld a, [hl]
            copy [WRAM_FRAME_COUNTER], a
            ; pop hl

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
            ld a, [rSONGMAP]
            ld h, a
            ld a, [rSONGMAP + 1]
            ld l, a

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