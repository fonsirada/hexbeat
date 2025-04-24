; header

include "src/hardware.inc"
include "src/joypad.inc"
include "src/sprites.inc"
include "src/utils.inc"


section "sound", rom0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/* MOVED TO WRAM.INC
rsset (_RAM + $40) ; change this location at some point

def WRAM_PAD_INPUT                  rb 0 ;sizeof_PAD_INPUT
def WRAM_FRAME_COUNTER              rb 1
def WRAM_NOTE_INDEX                 rb 1

def WRAM_END                        rb 0
*/

; sanity checks
def WRAM_USAGE                      equ (WRAM_END - _RAM)
println "WRAM usage: {d:WRAM_USAGE} bytes"
assert WRAM_USAGE <= $2000, "Too many bytes used in WRAM"

; ROM usage
def TIME_BETWEEN_NOTES          equ (10)
;equ %1100000

Ch1_Notes:
;continuous example notes (scale)
dw $060b, $0642, $0672, $0689, $06b2, $06d6, $06f7, $0706
;dw $c689, $c6b2, $c6c4, $c6c4, $c689, $c6b2, $c6c4, $c6b2

Ch2_Notes:
; full_test notes (???)
; B3,  C4,  C#4, D4
;dw $EDC5, $0BC6, $27C6, $42C6, $5BC6, $0BC6, $27C6, $42C6

; music draft 1:
; bass? ; g2, g#2
;dw $c2c7, $c2c7, $c312, $c312, $c2c7, $c2c7, $c312, $c312
; melody (r24 then r23)
dw $c689, $c6b2, $c6c4, $c6c4, $c689, $c6b2, $c6c4, $c6b2
dw $8689, $86b2, $86c4, $86c4, $8689, $86b2, $86c4, $86b2
dw $0000




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; functions
init_sound:
    ; init the WRAM state
    ;InitJoypad WRAM_PAD_INPUT
    copy [WRAM_FRAME_COUNTER], 0;$FF ;$FF to disable, 0 to enable
    xor a
    ld [WRAM_NOTE_INDEX], a

    ; init the sound
    copy [rNR52], AUDENA_ON

    ; high nibble = left speaker vol
    ; low nibble = right speaker vol
    copy [rNR50], $77

    copy [rNR51], $FF


    ret

update_music:
    ;; go to next note ;;
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
            ld hl, Ch2_Notes
            add hl, de
    
            ; get note; if note is 0, stop sound
            ld a, [hli]
            or a, a
            jr nz, .stop_sound
                xor a
                ld [WRAM_NOTE_INDEX], a
                
                ; copy [rNR12], $00
                ; copy [rNR14], $C0

                ; copy [rNR22], $00
                ; copy [rNR24], $C0
                ; ld a, $FF
                ; ld [WRAM_FRAME_COUNTER], a
                ; jr .play_notes
            .stop_sound

            ld [rNR23], a
            ld a, [hli]
            ld [rNR24], a

            copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
        .sound_switch

    .play_notes
    ld a, [rGAME]
    bit GAMEB_START, a ; need diff condition, one that unflags
    jr z, .started_notes
        ld a, [PAD_CURR]
        bit PADB_START, a
        jr nz, .started_notes
            ; play note (load in note to channels)
            ;ld [WRAM_NOTE_INDEX], a

            ;; CHANNEL 1 ;;

            ;; CHANNEL 2 ;;
            copy [rNR21], $80 
            copy [rNR22], $F6;$F0

            ; init first note & start sound
            ld hl, Ch2_Notes
            ld a, [hli]
            ld [rNR23], a
            ld a, [hl]
            or a, $80
            ld [rNR24], a

            ;; CHANNEL 3 ;;

            copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
    .started_notes
    ret

update_sound:
    call update_music
    ;;; theory crafting ;;;
    ; - need time for spell to reach target's center
    ;   pixels: x = 50; midpoint = 54; total px = 168
    ;   spell speed = 2 / 3 / 4
    ;   if spawning at 168, takes 114 px / spell speed
    ;   assume 57 / 38 / 28.5 spell updates to reach target
    ;   2 halts per cycle & spells update every cycle
    ;   total of 114 / 76 / 57 vblanks per note
    ;   
    ;   WRAM FRAME COUNTER decs every cycle (eg per 2 halts)
    ;   spell must spawn when frame counter is -38
    ret 

UpdateSample:
    halt

    ;UpdateJoypad WRAM_PAD_INPUT
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
            ld hl, Ch2_Notes
            add hl, de

            ; get note; if note is 0, stop sound
            ld a, [hli]
            or a, a
            jr nz, .stop_sound
                ld a, 0
                ld [WRAM_NOTE_INDEX], a
                ; play infinitely??
                ; find where that fade is coming from...
                
                ; copy [rNR12], $00
                ; copy [rNR14], $C0

                ; copy [rNR22], $00
                ; copy [rNR24], $C0
                ld a, $FF
                ld [WRAM_FRAME_COUNTER], a
                jr .play_notes
            .stop_sound

            ld [rNR23], a
            ld a, [hli]
            ld [rNR24], a

            ;; channel 1 notes are broken rn
            ; ld hl, Ch1_Notes
            ; add hl, de
            ; ld [rNR13], a
            ; ld a, [hli]
            ; ld [rNR14], a

            copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
        .sound_switch

    .play_notes

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; NOTE: move this to a seperate func

    ; start playing notes when start is pressed
    ld a, [PAD_CURR]
    bit PADB_START, a
    jr nz, .start_notes
        xor a
        ld [WRAM_NOTE_INDEX], a

        ;;; CHANNEL 1 ;;;
        copy [rNR10], $00
        copy [rNR11], $80
        copy [rNR12], $F0

        ; ld hl, Ch1_Notes
        ; ld a, [hli]
        ; ld [rNR13], a
        ; ld a, [hl]
        ; or a, $80
        ; ld [rNR14], a
        
        ;;; CHANNEL 2 ;;;
        ; high nibble = duty (0, 4, 8, C)
        ; low nibble = length (00-3F)
        copy [rNR21], $80 

        ; high nibble = volume (0-F)
        ; low nibble = envelope (down, 0-7; up, 8-F)
        copy [rNR22], $F6;$F0

        ; init first note & start sound
        ld hl, Ch2_Notes
        ld a, [hli]
        ld [rNR23], a
        ld a, [hl]
        or a, $80
        ld [rNR24], a

        copy [WRAM_FRAME_COUNTER], TIME_BETWEEN_NOTES
    .start_notes

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sound, update_sound, UpdateSample