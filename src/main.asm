;
; CS-240 World 5: Basic Game Functionality
;
; @file main.asm
; @author Darren Strash
; @date March 4, 2025
;
; build with:
; make

include "src/hardware.inc"
include "src/joypad.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "header", rom0[$0100]
entrypoint:
    di
    jp main
    ds ($0150 - @), 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

macro DisableLCD
    ; wait for the vblank
    .wait_vblank\@
        ld a, [rLY]
        cp a, SCRN_Y
        jr nz, .wait_vblank\@

    ; turn the LCD off
    xor a
    ld [rLCDC], a
endm

section "main", rom0
main:
    DisableLCD
    call InitSample
    InitJoypad
    .loop
        call UpdateSample
        UpdateJoypad
        jr .loop
