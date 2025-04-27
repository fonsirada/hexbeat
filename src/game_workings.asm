; 
; CS-240 World 8: [name]
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

; init registers
; set up game and player settings
init_registers:
    ld a, GAMEF_BASE 
    ld [rGAME], a
    ld [rGAME_DIFF], a
    ld [rCOLLISION], a
    ld [rTIMER_BG], a
    ld [rTIMER_PC], a
    ld [rTIMER_OBJ], a
    ld [rTIMER_DMG], a

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
    cp a, 0
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
        ld a, [rGAME]
        bit GAMEB_LVL2, a
        jr nz, .done_check
            RegBitOp rGAME, GAMEB_LVL2, set
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
        ld a, [rGAME]
        bit GAMEB_BOSSLVL, a
        jr nz, .done_check
            call init_level_3
            RegBitOp rGAME, GAMEB_BOSSLVL, set
    .done_check
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
export init_registers, update_timers, is_game_over, check_level_2, check_boss_level