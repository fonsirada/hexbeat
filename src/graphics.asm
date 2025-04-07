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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "sample", rom0

InitGraphics:
    ; init the palettes
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld a, %00011011
    ld [rOBP1], a

    ; init graphics data
    InitOAM
    LoadGraphicsDataIntoVRAM

    ; enable the vblank interrupt
    ld a, IEF_VBLANK
    ld [rIE], a
    ei

    ; set bg to start screen
    copy [rSCY], 120

    ; hide window offscreen
    copy [rWX], 7
    copy [rWY], 136
 

    ; set macro data
    ld a, GAME_BASE ; load settings here
    ld [rGAME], a ; load (a) into the data 'register'

    ret

UpdateGraphics:
    halt

    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; jump when 'a' is held
    bit PADB_A, a
    jr nz, .done_jumping
        ; using b as a counter for jump height
        push af
        push bc
        call Jump
        pop bc
        copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0
        pop af
    .done_jumping

    ; if started (screen Y = 0), start bg scrolling
    ld a, [rGAME]
    bit 0, a
    jr z, .end_update
        ld a, [rSCX]
        inc a
        ld [rSCX], a
    .end_update
    ret

;;; START SCREEN FUNCTIONALITY
; storing macro game data in $C004 for now
; bits: GAME_START | GAME_END | _ | _ | _ | _ | _ | _ 
Start:
    halt ; --> is there a better placement to avoid slowing down the game?

    push af

    ; check if game started
    ld a, [rGAME]
    bit 0, a
    jr nz, .done_starting 

    ; *check indent formatting here
    ; check if START was pressed
    ld a, [PAD_CURR]
    bit PADB_START, a
    jr nz, .done_starting
        ; move window to bottom of the LCD for UI (getting rid of start screen)
        ld a, 0
        ld [rSCY], a
        ld a, 112
        ld [rWY], a

        call MovePlayerToStart
        call MoveSpritesToStart
    
        ld a, [rGAME] ; TO-DO: make a macro for this
        set 0, a
        ld [rGAME], a
    .done_starting

    pop af
    ret


export InitGraphics, UpdateGraphics, Start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_16mode.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/w5_window_v1.tlm"