;
; CS-240 World 4: Moving window and assets
;
; @file graphics.asm
; @author Sydney Chen & Alfonso Rada
; @date March 10, 2025
;

include "src/hardware.inc"

section "graphics_functions", rom0

; CONSTANTS
def TILES_COUNT                     equ (384)
def BYTES_PER_TILE                  equ (16)
def TILES_BYTE_SIZE                 equ (TILES_COUNT * BYTES_PER_TILE)

def TILEMAPS_COUNT                  equ (2)
def BYTES_PER_TILEMAP               equ (1024)
def TILEMAPS_BYTE_SIZE              equ (TILEMAPS_COUNT * BYTES_PER_TILEMAP)

def GRAPHICS_DATA_SIZE              equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
def GRAPHICS_DATA_ADDRESS_END       equ ($8000)
def GRAPHICS_DATA_ADDRESS_START     equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)

def WINDOW_UPPER_THRESHOLD          equ $47
def WINDOW_MOVEMENT_TOGGLE          equ $C000
def WINDOW_MOVING_UP                equ 0
def WINDOW_MOVING_DOWN              equ 1

def DEFAULT_PALETTE                 equ %11100100

section "vblank_interrupt", rom0[$0040]
    reti

macro LoadGraphicsDataIntoVRAM
    ld de, GRAPHICS_DATA_ADDRESS_START
    ld hl, _VRAM8000
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, d
        cp a, high(GRAPHICS_DATA_ADDRESS_END)
        jr nz, .load_tile\@
endm

macro DisableLCD
    .wait_vblank\@
        ld a, [rLY]
        cp a, SCRN_Y
        jr nz, .wait_vblank\@

    ; turn the LCD off
    xor a
    ld [rLCDC], a
endm

init_graphics:
    DisableLCD
    
    ; initialize palette
    ld a, DEFAULT_PALETTE
    ld [rBGP], a

    LoadGraphicsDataIntoVRAM

    ld a, IEF_VBLANK
    ld [rIE], a
    ei

    ; set window parameters, currently offscreen
    ld a, WX_OFS
    ld [rWX], a
    ld a, 119
    ld [rWY], a

    ; set graphics parameters and turn back LCD on
    ld a, LCDCF_ON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_WIN9C00 | LCDCF_WINON
    ld [rLCDC], a

    ret


; ; moves the window during a vblank
; update_window:
;     halt
;     halt
;     halt

;     push bc
;     push af

;     ld a, [rWY]
;     ld b, a

;     ; bring up window
;     cp SCRN_Y
;     jr nz, .check_upper_threshold
;         ld a, WINDOW_MOVING_UP
;         ld [WINDOW_MOVEMENT_TOGGLE], a
;         jr .move_window

;     .check_upper_threshold
;         ld a, b
;         cp WINDOW_UPPER_THRESHOLD
;         jr nz, .move_window
;             ld a, WINDOW_MOVING_DOWN
;             ld [WINDOW_MOVEMENT_TOGGLE], a

;     .move_window
;     ; check if window is moving up or down
;     ld a, [WINDOW_MOVEMENT_TOGGLE]
;     xor WINDOW_MOVING_DOWN
;     jr z, .window_down
;         ; bring window up
;         dec b
;         dec b

;     .window_down
;     inc b

;     ld a, b
;     ld [rWY], a

;     pop af
;     pop bc

;     ret

export init_graphics
export update_window

; GRAPHICS ASSETS
section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/witch_tileset.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/witch_bg_hall_v1.tlm"
; incbin  "window.tlm"