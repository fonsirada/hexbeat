; 
; CS-240 World 8: Your final, polished game
;
; @file game_workings.asm
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 27, 2025
; @brief store functions related to general game operations

include "src/utils.inc"
include "src/joypad.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def PLAYER_HEALTH                   equ 10

def BG_ANIMATION_TIMER              equ 1
def PC_ANIMATION_TIMER              equ 3
def OBJ_ANIMATION_TIMER             equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "game_workings", rom0

; initializes the game
initialize:
    DisableLCD

    call init_graphics
    call init_sound
    call init_registers
    call init_sprite_data
    call init_player
    call init_sprites
    InitJoypad

    EnableLCD
    ret

; updates the game, only if the game has been started and has not been ended
update_game:
    ld a, [rGAME]
    bit GAMEB_START, a
    jr z, .return
        bit GAMEB_END, a
        jr z, .updates
            ; set up game over screen when game ends
            call game_over
            ld a, [rGAME]
            bit GAMEB_END, a
            jr nz, .return
                ; reinitialize game if restarted
                call initialize
                jr .return
    
        .updates
        call update_timers
        call update_graphics
        call update_sound

        call update_sprites_spawning
        halt
        call update_sprites

        halt
        call update_player

        call check_level_2
        call check_boss_level
        call is_game_over
        
    .return
    UpdateJoypad
    ret

; init registers - set up game and player settings
init_registers:
    ld a, GAMEF_BASE 
    ld [rGAME], a
    ld [rGAME_DIFF], a
    ld [rCOLLISION], a
    ld [rTIMER_BG], a
    ld [rTIMER_PC], a
    ld [rTIMER_OBJ], a
    ld [rTIMER_DMG], a
    ld [rGAME_LVL], a

    ; load player-related values
    ld [rPLAYER], a
    ld [rPC_ACOUNT], a
    copy [rPC_HEALTH], PLAYER_HEALTH 

    ; load sprite-related values
    copy [rSPELL_COUNT], LVL1_SPELL_NUM
    ret

update_timers:
    IncTimer rTIMER_BG, BG_ANIMATION_TIMER
    IncTimer rTIMER_PC, PC_ANIMATION_TIMER
    IncTimer rTIMER_OBJ, OBJ_ANIMATION_TIMER
    ret

; game over and level checks
is_game_over:
    ld a, [rPC_HEALTH]
    or a
    jr nz, .check_overflow
        RegBitOp rGAME, GAMEB_END, set
        jr .check_done
    .check_overflow
        cp a, PLAYER_HEALTH + 1
        jr c, .check_done
            RegBitOp rGAME, GAMEB_END, set
    .check_done
    ret

; check if the level 2 threshold is passed
check_level_2:
    ld a, [rGAME_DIFF]
    cp a, GAME_DIFF_THRES_LVL2
    jr nz, .done_check
        ld a, [rGAME_LVL]
        or a
        jr nz, .done_check
            call init_level_2
    .done_check
    ret

;check if game is currently on boss level + handle accordingly
check_boss_level:
    ld a, [rGAME_DIFF]
    cp GAME_DIFF_THRES_WIN
    jr nz, .check_boss_level_thres
        RegBitOp rGAME, GAMEB_END, set
        jr .done_check

    .check_boss_level_thres
    cp GAME_DIFF_THRES_BOSSLVL
    jr nz, .done_check
        ld a, [rGAME_LVL]
        ; level 2 is 1 in rGAME_LVL
        cp 1
        jr nz, .done_check
            call init_boss_level

    .done_check
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
export initialize, update_game