; 
; CS-240 World 5: Basic Game Functionality
;
; @file graphics.asm
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 7, 2025
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

def BG_SCROLL_SPEED                 equ 2

def PALETTE_0                       equ %11100100
def PALETTE_1                       equ %00011011

def START_SCY                       equ 120
def WY_OFS                          equ 136
def LEVEL_SCY                       equ 0
def UI_Y                            equ 112

def WIN_HEALTH_END                  equ $9C2B

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; load the graphics data from ROM to VRAM
macro LoadGraphicsDataIntoVRAM
    ld de, GRAPHICS_DATA_ADDRESS_START
    ld hl, _VRAM8000
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, d
        cp high(GRAPHICS_DATA_ADDRESS_END)
        jr nz, .load_tile\@
endm

; clear the OAM
macro InitOAM
    ld c, OAM_COUNT
    ld hl, _OAMRAM + OAMA_Y
    ld de, sizeof_OAM_ATTRS
    .init_oam\@
        ld [hl], 0
        add hl, de
        dec c
        jr nz, .init_oam\@
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics", rom0 

init_graphics:
    ld a, PALETTE_0
    ld [rBGP], a
    ld [rOBP0], a
    ld a, PALETTE_1
    ld [rOBP1], a

    ; init graphics data
    InitOAM
    LoadGraphicsDataIntoVRAM

    ld a, IEF_VBLANK
    ld [rIE], a
    ei

    ; set bg to start screen & hide window offscreen
    copy [rSCY], START_SCY
    copy [rWX], WX_OFS
    copy [rWY], WY_OFS
 
    ; set up game and player settings
    ; there's gotta be a better way to do this -S
    ld a, GAME_BASE 
    ld [rGAME], a
    ld [rPLAYER], a
    copy [rPC_HEALTH], 10 ; magic number, fix
    ld [rPC_ACOUNT], a
    ld [rCOLLISION], a
    ld [rTIMER_BG], a ; make an initialize timers func
    ld [rTIMER_PC], a
    ld [rTIMER_OBJ], a
    ld [rTIMER_OBJ2], a

    ret

update_graphics:
    ; halt
    CheckTimer rTIMER_BG, 1
    jr nz, .done_update

        ; scroll bg
        ld a, [rSCX]
        add BG_SCROLL_SPEED
        ld [rSCX], a

    .done_update
    call update_window

    ret


; $22 to $2B in the 9C00 map
; $3C (full) | $3D (half) | $3E (empty)
update_window:
    ld hl, WIN_HEALTH_END

    .loop
        ld a, l
        sub a, $21
        ld b, a

        ld a, [rPC_HEALTH]
        cp a, b
        jr nz, .check_empty
            ; replace with half-filled bar
            ld [hl], $3D
            jr .next_hbar_tile
        .check_empty
        cp a, b
        jr nc, .next_hbar_tile
            ; replace with empty bar
            ld [hl], $3E
        
        .next_hbar_tile
        dec hl
        ld a, l
        cp a, $21
        jr nz, .loop
    ret 

update_timers:
    IncTimer rTIMER_BG, 1
    IncTimer rTIMER_PC, 3 ; figure out how to swap between 4 & 8
    IncTimer rTIMER_OBJ, 1
    ret

; set-up game + remove start screen once START is pressed
start:
    halt

    ; check if game started
    ld a, [rGAME]
    bit GAMEB_START, a
    jr nz, .done_starting

        ld a, [PAD_CURR]
        bit PADB_START, a
        jr nz, .done_starting
            ; set up level screen
            ld a, LEVEL_SCY
            ld [rSCY], a
            ld a, UI_Y
            ld [rWY], a

            call move_player_to_start
            call move_sprites_to_start
            RegBitOp rGAME, GAMEB_START, set

    .done_starting
    ret

game_over:
    ; add visuals/text
    ; add press enter to restart functionality
    .done
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_graphics, update_graphics, start, game_over, update_timers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_16mode.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/w5_window_v1.tlm"