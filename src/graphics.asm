; 
; CS-240 World 5: Basic Game Functionality
;
; @file graphics.asm
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @brief store overall graphics-related functions

include "src/utils.inc"
include "src/joypad.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "vblank_interrupt", rom0[$0040]
    reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def TILES_COUNT                     equ (384)
def BYTES_PER_TILE                  equ (16)
def TILES_BYTE_SIZE                 equ (TILES_COUNT * BYTES_PER_TILE)

def TILEMAPS_COUNT                  equ (2)
def BYTES_PER_TILEMAP               equ (1024)
def TILEMAPS_BYTE_SIZE              equ (TILEMAPS_COUNT * BYTES_PER_TILEMAP)

def GRAPHICS_DATA_SIZE              equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
def GRAPHICS_DATA_ADDRESS_END       equ ($8000)
def GRAPHICS_DATA_ADDRESS_START     equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)

def PALETTE_0                       equ %11100100
def PALETTE_1                       equ %00011011

def START_SCY                       equ 120
def WY_OFS                          equ 136
def LEVEL_SCY                       equ 0
def UI_Y                            equ 112

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "sample", rom0 ; should this stay as "sample"?

InitGraphics:
    ; init the palettes
    ld a, PALETTE_0
    ld [rBGP], a
    ld [rOBP0], a
    ld a, PALETTE_1
    ld [rOBP1], a

    ; init graphics data
    InitOAM
    LoadGraphicsDataIntoVRAM

    ; enable the vblank interrupt
    ld a, IEF_VBLANK
    ld [rIE], a
    ei

    ; set bg to start screen
    copy [rSCY], START_SCY

    ; hide window offscreen
    copy [rWX], WX_OFS
    copy [rWY], WY_OFS
 

    ; set up game and player settings
    ld a, GAME_BASE 
    ld [rGAME], a
    ld [rPLAYER], a

    ret

; background scrolling
UpdateGraphics:
    halt

    ; if started, start bg scrolling
    ld a, [rGAME]
    bit GAMEB_STARTED, a
    jr z, .end_update
        ld a, [rSCX]
        inc a
        ld [rSCX], a

    .end_update
    ret

;;; START SCREEN FUNCTIONALITY - still need this?
; storing macro game data in $C004 for now
; bits: GAME_START | GAME_END | _ | _ | _ | _ | _ | _ 
Start:
    halt ; --> is there a better placement to avoid slowing down the game?

    ; check if game started
    ld a, [rGAME]
    bit GAMEB_STARTED, a
    jr nz, .done_starting
        ld a, [PAD_CURR]
        bit PADB_START, a
        jr nz, .done_starting
            ; set up level screen
            ld a, LEVEL_SCY
            ld [rSCY], a
            ld a, UI_Y
            ld [rWY], a

            call MovePlayerToStart
            call MoveSpritesToStart
            StartGame

    .done_starting
    ret


export InitGraphics, UpdateGraphics, Start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_16mode.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/w5_window_v1.tlm"