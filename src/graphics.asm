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

section "text", rom0
GAME_OVER:
    ; the tile ID's for each character in "GAME OVER\nPRESS SELECT\nTO RESTART"
    db $FE, $F8, $0C, $FC, $2A, $0E, $1D, $FC, $19, $0A, $0F, $19, $FC, $1A, $1A, $2A, $1A, $FC, $0B, $FC, $FA, $1B, $0A, $1B, $0E, $2A, $19, $FC, $1A, $1B, $F8, $19, $1B

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
def BG_ANIMATION_TIMER              equ 1
def UPDATE_FRAME                    equ 1
def PC_ANIMATION_TIMER              equ 3
def OBJ_ANIMATION_TIMER             equ 2

def PALETTE_0                       equ %11100100
def PALETTE_1                       equ %00011011

def START_SCY                       equ 120
def START_SCX                       equ 0
def WY_OFS                          equ 136
def LEVEL_SCY                       equ 0
def UI_Y                            equ 112

def PLAYER_HEALTH                   equ 10

def HEALTH_BAR_TILE_OFFSET          equ $21
def HEALTH_HALF_TILEID              equ $3D
def HEALTH_EMPTY_TILEID             equ $3E
def HEALTH_FULL_TILEID              equ $3C

def O_TILE_ID                       equ $0E
def N_TILE_ID                       equ $0D
def E_TILE_ID                       equ $FC
def T_TILE_ID                       equ $1B
def W_TILE_ID                       equ $1E

; start on row 2 of screen which starts at $9880
def TEXT_START_LOCATION             equ $9880
def NEW_LINE                        equ $0A
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

init_registers:
    ; set up game and player settings
    ld a, GAME_BASE 
    ld [rGAME], a
    ld [rGAME_DIFF], a
    ld [rPLAYER], a
    copy [rPC_HEALTH], PLAYER_HEALTH 
    ld [rPC_ACOUNT], a
    ld [rCOLLISION], a
    ld [rTIMER_BG], a
    ld [rTIMER_PC], a
    ld [rTIMER_OBJ], a
    copy [rSPELL_COUNT], LVL1_SPELL_NUM
    ret

update_graphics:
    ; halt
    CheckTimer rTIMER_BG, UPDATE_FRAME
    jr nz, .done_update

        ; scroll bg
        ld a, [rSCX]
        add BG_SCROLL_SPEED
        ld [rSCX], a

    .done_update
    call update_window

    ret


; loop thru the healh bar tiles in window, 
; and replace according to player health
; NOTE: tiles $22 to $2B in the 9C00 map
; NOTE: $3C (full) | $3D (half) | $3E (empty)
update_window:
    call level_text

    ld hl, WIN_HEALTH_END

    .loop
        ld a, l
        sub a, HEALTH_BAR_TILE_OFFSET
        ld b, a

        ld a, [rPC_HEALTH]
        cp a, b
        jr nz, .check_empty
            ; replace with half-filled bar
            ld [hl], HEALTH_HALF_TILEID
            jr .next_hbar_tile
        .check_empty
        cp a, b
        jr nc, .load_full
            ; replace with empty bar
            ld [hl], HEALTH_EMPTY_TILEID
            jr .next_hbar_tile

        .load_full
            ; replace with a full bar
            ld [hl], HEALTH_FULL_TILEID
        
        .next_hbar_tile
        dec hl
        ld a, l
        cp a, HEALTH_BAR_TILE_OFFSET
        jr nz, .loop
    ret 

level_text:
    ld hl, LEVEL_TEXT_START

    ld a, [rGAME]
    bit GAMEB_LVL2, a
    jr nz, .print_level_2
        ld [hl], O_TILE_ID
        inc hl
        ld [hl], N_TILE_ID
        inc hl
        ld [hl], E_TILE_ID
        inc hl
        jr .done

    .print_level_2
    ld [hl], T_TILE_ID
    inc hl
    ld [hl], W_TILE_ID
    inc hl
    ld [hl], O_TILE_ID
    inc hl

    .done
    ret

update_timers:
    IncTimer rTIMER_BG, BG_ANIMATION_TIMER
    IncTimer rTIMER_PC, PC_ANIMATION_TIMER
    IncTimer rTIMER_OBJ, OBJ_ANIMATION_TIMER
    ret

; reads for START press on the title screen and sets up the level screen
start:
    push af
    ; read if START button has been pressed ONLY if the game has NOT been started yet
    ld a, [rGAME]
    bit GAMEB_START, a
    jr nz, .return
        halt
        ; move bg and window to start screen positions
        copy [rSCY], START_SCY
        copy [rSCX], START_SCX
        copy [rWX], WX_OFS
        copy [rWY], WY_OFS

        ld a, [PAD_CURR]
        bit PADB_START, a
        ; if START is not pressed, jump to end (main game loop will keep jumping to updatejoypad since game isn't started yet)
        jr nz, .return
            ; if START is pressed, set up the level
            ld a, LEVEL_SCY
            ld [rSCY], a
            ld a, UI_Y
            ld [rWY], a
            call move_player_for_level
            call init_level_1
            ; set flag that says the game has been started for main loop
            RegBitOp rGAME, GAMEB_START, set

    .return
    pop af
    ret

; print game over text and check if restarted
game_over:
    push af
    push de
    push hl
    push bc

    halt
    call print_text

    ld a, [PAD_CURR]
    bit PADB_SELECT, a
    jr nz, .done_end
        RegBitOp rGAME, GAMEB_END, res

    .done_end
    pop bc
    pop hl
    pop de
    pop af
    ret

; prints the game over text from ROM
print_text:
    call find_center_tile
    ld de, GAME_OVER 

    .print_tiles_loop
        ld a, [de]
        ; check if reached end of string
        cp 0
        jr z, .done
            ; check if reached new-line
            cp NEW_LINE
            jr nz, .load_tile
                ; move text location one row down
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

find_center_tile:
    ld hl, TEXT_START_LOCATION 

    ld a, [rSCX]
    ; get the corresponding background tile column
    srl a
    srl a
    srl a
    ; get to the center of the screen
    add SCREEN_CENTER_OFFSET
    ld c, a
    ld b, 0
    ; set VRAM address to center tile of the screen
    add hl, bc

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_graphics, init_registers, update_graphics, start, game_over, update_timers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_16mode.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/w5_window_v1.tlm"