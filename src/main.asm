;
; CS-240 World 5: Basic Game Functionality
;
; @file main.asm
; @author Darren Strash
; @date March 4, 2025
;
; build with:
; make

def ROM_HEADER_ADDRESS      equ $0100
def ROM_MAIN_ADDRESS        equ $0150

section "header", rom0[ROM_HEADER_ADDRESS]
    ; disable interrupts and jump to main
    di
    jr main

section "main", rom0[ROM_MAIN_ADDRESS]
main:
    call init_graphics
    .loop
        call update_window
        jr .loop
