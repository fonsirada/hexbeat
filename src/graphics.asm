; build with
; rgbasm -o main.o main.asm && rgblink --tiny -o joypad.gb main.o && rgbfix -v -p 0xFF joypad.gb

include "src/utils.inc"
include "src/joypad.inc"


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

def SPRITE_0_ADDRESS equ (_OAMRAM)
def SPRITE_1_ADDRESS equ (_OAMRAM + sizeof_OAM_ATTRS)


; load the graphics data from ROM to VRAM
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

section "sample", rom0

InitSample:
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

    ; set background parameters
    ld a, 24
    ld [rSCY], a

    ; place the window at the bottom of the LCD
    ld a, 7
    ld [rWX], a
    ld a, 120
    ld [rWY], a

    ; set the first sprite
    copy [SPRITE_0_ADDRESS + OAMA_X], 16
    copy [SPRITE_0_ADDRESS + OAMA_Y], 32
    copy [SPRITE_0_ADDRESS + OAMA_TILEID], 16
    copy [SPRITE_0_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; set the second sprite
    copy [SPRITE_1_ADDRESS + OAMA_Y], 80
    copy [SPRITE_1_ADDRESS + OAMA_X], 80
    copy [SPRITE_1_ADDRESS + OAMA_TILEID], 0
    copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0 | OAMF_XFLIP

    ; set the graphics parameters and turn back LCD on
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINON | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ld [rLCDC], a

    ret

UpdateSample:
    halt

    ; get the joypad buttons that are being held!
    ld a, [PAD_CURR]

    ; Is right being held?
    bit PADB_RIGHT, a
    jr nz, .done_moving_right
    ; perform action
        ; move right
        ld a, [SPRITE_1_ADDRESS + OAMA_X]
        inc a
        ld [SPRITE_1_ADDRESS + OAMA_X], a
        copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0
    .done_moving_right

    ret

export InitSample, UpdateSample

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/witch_tileset.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/w5_window_v1.tlm"