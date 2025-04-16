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
    ld [rGAME_DIFF], a
    ld [rPLAYER], a
    copy [rPC_HEALTH], 10 ; magic number --> PLAYER_HEALTH
    ld [rPC_ACOUNT], a
    ld [rCOLLISION], a
    ld [rTIMER_BG], a ; make an initialize timers func?
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
    IncTimer rTIMER_OBJ, 2
    ret

; set-up game + remove start screen once START is pressed
start:
    halt

    ; read if START button has been pressed ONLY if the game has NOT been started yet
    ld a, [rGAME]
    bit GAMEB_START, a
    jr nz, .return
        ld a, [PAD_CURR]
        bit PADB_START, a
        ; if button is not pressed, jump to end (main game loop will keep jumping to updatejoypad since game isn't started yet)
        jr nz, .return
            ; if button is pressed, set up the level
            ld a, LEVEL_SCY
            ld [rSCY], a
            ld a, UI_Y
            ld [rWY], a

            call move_player_for_level
            call move_sprites_for_level
            RegBitOp rGAME, GAMEB_START, set

    .return
    ret

game_over:
    halt 
    push hl
    push de
    call game_over_text
    pop de
    pop hl
    ; check if game ended
    ld a, [rGAME]
    bit GAMEB_END, a
    jr nz, .done_end
        ld a, [PAD_CURR]
        bit PADB_START, a
        ; fix this (restarting game)
        jr nz, .done_end
            ; set up level screen
            ld a, LEVEL_SCY
            ld [rSCY], a
            ld a, UI_Y
            ld [rWY], a

            call move_player_for_level
            call move_sprites_for_level
            RegBitOp rGAME, GAMEB_START, set
            RegBitOp rGAME, GAMEB_END, res

    ; add visuals/text
    ; add press enter to restart functionality
    .done_end
    ret

game_over_text:
    db "GAMEOVER\0"
    ld de, $08A1 ; where the string is stored in ROM
    ld hl, $98E0 ; de will store tile address where text will be printed starting at $98E0 since the Y value never changes, 
                    ;the center tile on the screen will always be on row 7 which starts at $98E0

    ; calculating the starting tile where text will be printed (center of screen)
    ld a, [rSCX]
    ; divide by 8 to get the tile that corresponds to the SCX
    srl a
    srl a
    srl a
    ; add 10 tiles to get to the center of the screen
    add 10
    ld c, a
    ld b, 0
    ; set the VRAM address to the tile that is at the center of the screen
    add hl, bc

    .print_tiles_loop
        ; load the tile that corresponds to the character into the corresponding VRAM address
        ; load the ASCII value of the character from the string into a
        ld a, [de]
        ; if the value of [hl] is 0, you've reached the end of the string
        cp 0
        jr z, .done
            cp 20
            jr nz, .letter
                ; gives blank tile for ' ' in string
                ld a, $2A
                jr .load_tile

            .letter
            ; subtracting $41 since $41 is the ASCII for 'A'
            sub $41
            cp 24
            jr c, .check_block3
                ; block 4 if >= 24 (y and z)
                sub 24
                add $30
                jr .load_tile

            .check_block3
            cp 16
            jr c, .check_block2
                ; block 3 if >= 16 but < 24 (q - x)
                ; subtract 16 for the offset
                sub 16
                add $20
                jr .load_tile
            
            .check_block2
            cp 8
            jr c, .load_tile
                ; block 2 if >= 8 but < 16 (i - p)
                ; subtract 8 for the offset
                sub 8
                add $10

            .load_tile
            ; tile 'A' is at tile index 248
            add $F8
            ld [hl], a
            inc hl
            inc de
            jr .print_tiles_loop

    .done
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_graphics, update_graphics, start, game_over, update_timers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "assets/tileset_16mode.chr"
incbin "assets/witch_bg_hall_v1.tlm"
incbin "assets/w5_window_v1.tlm"