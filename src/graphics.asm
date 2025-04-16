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
GAMEOVER_STRING:
    db "GAME OVER\nPRESS SELECT\nTO RESTART\0"

LEVEL_STRING:
    db "LVL 2"

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
def START_SCX                       equ 0
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
    ;copy [rSCY], START_SCY
    ;copy [rWX], WX_OFS
    ;copy [rWY], WY_OFS

    ret

init_registers:
    ; set up game and player settings
    ; there's gotta be a better way to do this -S
    ld a, GAME_BASE 
    ld [rGAME], a
    ld [rGAME_DIFF], a
    ld [rPLAYER], a
    copy [rPC_HEALTH], 10 ; magic number --> PLAYER_HEALTH
    ld [rPC_ACOUNT], a
    ld [rCOLLISION], a
    ld [rTIMER_BG], a ; make an initialize timers func?
    ld [rTIMER_PC], a
    ld [rTIMER_OBJ], a
    copy [rSPELL_COUNT], $38
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


; loop thru the healh bar tiles in window, 
; and replace according to player health
; NOTE: tiles $22 to $2B in the 9C00 map
; NOTE: $3C (full) | $3D (half) | $3E (empty)
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
        jr nc, .load_full
            ; replace with empty bar
            ld [hl], $3E
            jr .next_hbar_tile

        .load_full
            ; replace with a full bar
            ld [hl], $3C
        
        .next_hbar_tile
        dec hl
        ld a, l
        cp a, $21
        jr nz, .loop
    ret 

update_timers:
    IncTimer rTIMER_BG, 1
    IncTimer rTIMER_PC, 3
    IncTimer rTIMER_OBJ, 2;1
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
    ld de, GAMEOVER_STRING ; (de) stores where the string is stored in ROM

    .print_tiles_loop
        ; load the ASCII value of the character from the string into a
        ld a, [de]
        ; if the value is 0, you've reached the end of the string
        cp 0
        jr z, .done
            ; if the value is $0A, you've reached a newline - change VRAM address to be 1 row lower
            cp $0A
            jr nz, .space
                ld c, $16
                ld b, $00
                add hl, bc
                inc de
                jr .print_tiles_loop

        .space
            ; if the value is $20, you've reached a ' ' (space) character
            cp $20
            jr nz, .letter
                ; blank tile for ' ' in string
                ld a, $2A
                jr .load_tile

        .letter
            call calculate_tile_id

        .load_tile
            halt
            ld [hl], a
            inc hl
            inc de
            jr .print_tiles_loop

    .done
    ret

find_center_tile:
    ld hl, $9880 ; (hl) stores the VRAM address (tile location) where text will be printed 
                 ; starting at $9880 since the Y value never changes, start on row 2 which starts at $9880

    ld a, [rSCX]
    ; divide SCX by 8 to get the corresponding background tile column
    srl a
    srl a
    srl a
    ; add 10 tiles to get to the center of the screen (LCD is 20 tiles wide)
    add 8
    ld c, a
    ld b, 0
    ; each tile is 1 byte, so add the X tiles to the VRAM address to find the center tile of the screen
    add hl, bc

    ret

calculate_tile_id:
    ; subtracting $41 since $41 is the ASCII for 'A' (offset)
    sub $41
    cp 24
    jr c, .check_block3
        ; if the difference is >= 24, it's either 'Y' or 'Z' (block 4 in the tilemap)
        sub 24
        add $30
        jr .add_tile_a_offset

    .check_block3
    cp 16
    jr c, .check_block2
        ; if the difference is >= 16, it's between 'Q' and 'X' (block 3 in the tilemap)
        sub 16
        add $20
        jr .add_tile_a_offset
    
    .check_block2
    cp 8
    jr c, .add_tile_a_offset
        ; if the difference is >= 8, it's between 'I' and 'P' (block 2 in the tilemap)
        sub 8
        add $10

    .add_tile_a_offset
    ; tile 'A' starts at tile index 248, each block is $10 apart and the tiles in each block are 1 byte > the previous
    add $F8
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_graphics, init_registers, update_graphics, start, game_over, update_timers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_16mode.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/w5_window_v1.tlm"