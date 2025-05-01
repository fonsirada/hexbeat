; 
; HEXBEAT (CS-240 World 8)
;
; @file graphics.asm
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 30, 2025
; @license GNU GPL v3
; @brief store overall graphics-related functions

include "src/utils.inc"
include "src/joypad.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "vblank_interrupt", rom0[$0040]
    reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "text", rom0
YOU_LOSE:
    ; the tile ID's for each character in "GAME OVER\nPRESS SELECT\nTO RESTART"
    db $FE, $F8, $0C, $FC, $2A, $0E, $1D, $FC, $19, $0A, $0F, $19, $FC, $1A, $1A,\
    $2A, $1A, $FC, $0B, $FC, $FA, $1B, $0A, $1B, $0E, $2A, $19, $FC, $1A, $1B, $F8, $19, $1B, $00

YOU_WIN:
    ; the tile ID's for each character in "YOU WIN\nPRESS SELECT\nTO PLAY AGAIN"
    db $28, $0E, $1C, $2A, $1E, $08, $0D, $0A, $0F, $19, $FC, $1A, $1A, $2A, $1A,\
    $FC, $0B, $FC, $FA, $1B, $0A, $1B, $0E, $2A, $0F, $0B, $F8, $28, $2A, $F8, $FE, $F8, $08, $0D, $00

PrintLevelTable:
    ; function addresses for printing level text on the UI
    dw print_level_1
    dw print_level_2
    dw print_boss_level

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; GRAPHICS INFO
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

; BG & WINDOW
def UPDATE_FRAME                    equ 1
def BG_SCROLL_SPEED                 equ 2

def START_SCY                       equ 120
def START_SCX                       equ 0
def WY_OFS                          equ 136
def LEVEL_SCY                       equ 0
def UI_Y                            equ 112

def HEALTH_BAR_TILE_OFFSET          equ $21
def HEALTH_HALF_TILEID              equ $3D
def HEALTH_EMPTY_TILEID             equ $3E
def HEALTH_FULL_TILEID              equ $3C

; TEXT
def O_TILE_ID                       equ $0E
def N_TILE_ID                       equ $0D
def E_TILE_ID                       equ $FC
def T_TILE_ID                       equ $1B
def W_TILE_ID                       equ $1E
def B_TILE_ID                       equ $F9
def S_TILE_ID                       equ $1A

def TEXT_START_LOCATION             equ $9880
def NEW_LINE                        equ $0A
def END_OF_STRING                   equ 0
def ONE_ROW_LOWER_OFFSET            equ $0016
def SCREEN_CENTER_OFFSET            equ 8

def WIN_HEALTH_END                  equ $9C2B
def LEVEL_TEXT_START                equ $9C2E

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

    ret

update_graphics:
    CheckTimer rTIMER_BG, UPDATE_FRAME
    jr nz, .done_update
        ; scroll bg
        ld a, [rSCX]
        add BG_SCROLL_SPEED
        ld [rSCX], a

    .done_update
    call update_window
    ret

; display level text, loop thru the healh bar tiles and replace according to player health
update_window:
    call level_text

    ld hl, WIN_HEALTH_END
    .loop
        ld a, l
        sub HEALTH_BAR_TILE_OFFSET
        ld b, a

        ld a, [rPC_HEALTH]
        cp b
        jr nz, .check_empty
            ; half full
            ld [hl], HEALTH_HALF_TILEID
            jr .next_hbar_tile

        .check_empty
        cp b
        jr nc, .load_full
            ld [hl], HEALTH_EMPTY_TILEID
            jr .next_hbar_tile

        .load_full
        ld [hl], HEALTH_FULL_TILEID
        
        .next_hbar_tile
        dec hl
        ld a, l
        cp HEALTH_BAR_TILE_OFFSET
        jr nz, .loop

    ret 

print_level_1:
    ld hl, LEVEL_TEXT_START
    ld [hl], O_TILE_ID
    inc hl
    ld [hl], N_TILE_ID
    inc hl
    ld [hl], E_TILE_ID
    inc hl
    ret

print_level_2:
    ld hl, LEVEL_TEXT_START
    ld [hl], T_TILE_ID
    inc hl
    ld [hl], W_TILE_ID
    inc hl
    ld [hl], O_TILE_ID
    inc hl
    ret

print_boss_level:
    ld hl, LEVEL_TEXT_START
    ld [hl], B_TILE_ID
    inc hl
    ld [hl], O_TILE_ID
    inc hl
    ld [hl], S_TILE_ID
    inc hl
    ld [hl], S_TILE_ID
    inc hl
    ret

; prints text on UI (window) that displays current level - ONE for 1, TWO for 2, BOSS for 3
level_text:
    ld a, [rGAME_LVL]
    ld d, 0
    ld e, a
    ld hl, PrintLevelTable
    add hl, de
    add hl, de

    ld a, [hli]
    ld h, [hl]
    ld l, a
    CallHL

    ret

; reads START press on the title screen and sets up the level screen
start:
    ; only reads for START press if the game has NOT been started yet
    ld a, [rGAME]
    bit GAMEB_START, a
    jr nz, .return
        halt
        copy [rSCY], START_SCY
        copy [rSCX], START_SCX
        copy [rWX], WX_OFS
        copy [rWY], WY_OFS

        ld a, [PAD_CURR]
        bit PADB_START, a
        jr nz, .return
            call ui_sound

            ; set up level 1
            ld a, LEVEL_SCY
            ld [rSCY], a
            ld a, UI_Y
            ld [rWY], a
            call move_player_for_level
            call init_level_1
            RegBitOp rGAME, GAMEB_START, set

    .return
    ret

; print game over text and check if restarted
game_over:
    push af
    push de
    push hl
    push bc

    ; only call this once
    ld a, [rGAME]
    bit GAMEB_END_PRINT, a
    jr nz, .check_restart_game
        call print_text
        RegBitOp rGAME, GAMEB_END_PRINT, set
    
    .check_restart_game
    ld a, [PAD_CURR]
    bit PADB_SELECT, a
    jr nz, .done_end
        call ui_sound
        RegBitOp rGAME, GAMEB_END, res

    .done_end
    pop bc
    pop hl
    pop de
    pop af
    ret

; prints the game over text using the tile ID's stored in ROM
print_text:
    call find_center_tile

    ld a, [rGAME_DIFF]
    cp GAME_DIFF_THRES_WIN
    jr z, .win
        ld de, YOU_LOSE
        jr .print_tiles_loop
    .win
    ld de, YOU_WIN

    .print_tiles_loop
        halt
        ld a, [de]
        cp END_OF_STRING
        jr z, .done
            cp NEW_LINE
            jr nz, .load_tile
                ; move text location one row down, if new-line
                ld bc, ONE_ROW_LOWER_OFFSET
                add hl, bc
                jr .next_char
        
            .load_tile
            ld [hl], a
            inc hl

            .next_char
            inc de
            jr .print_tiles_loop

    .done
    ret

; loads (hl) with the VRAM address that corresponds to the tile on the center of the screen
find_center_tile:
    ld hl, TEXT_START_LOCATION 

    ld a, [rSCX]
    ; get the corresponding background tile column
    srl a
    srl a
    srl a
    ; get the center of the screen
    add SCREEN_CENTER_OFFSET
    ld c, a
    ld b, 0
    ; set VRAM address to center tile
    add hl, bc

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_graphics, update_graphics, start, game_over

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_16mode.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/w5_window_v1.tlm"