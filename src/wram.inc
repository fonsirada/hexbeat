; 
; CS 240: Storing Joypad state, including pressed/released/etc
;
; @file wram.inc
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 7, 2025
; @brief a place to store all WRAM variables

if !def(WRAM_RGBINC)
def WRAM_RGBINC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "src/hardware.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rsset _RAM
def PAD_CURR rb 1
def PAD_PREV rb 1
def PAD_PRSS rb 1
def PAD_RLSE rb 1
def PAD_LHOLD rb 1
def HOLD_A_COUNTER rb 1

;;; ADDITIONAL REGISTERS ;;;
def rGAME           rb 1
def rGAME_DIFF      rb 1
def rPLAYER         rb 1
def rPC_HEALTH      rb 1
def rPC_ACOUNT      rb 1
def rCOLLISION      rb 1
def rTIMER_BG       rb 1
def rTIMER_PC       rb 1
def rTIMER_OBJ      rb 1
def rSPELL_COUNT    rb 1

;;; rGAME
def GAME_BASE       equ %00000000
def GAME_START      equ %00000001
def GAME_END        equ %00000010
def GAME_LVL2       equ %00000100

def GAMEB_START     equ 0
def GAMEB_END       equ 1
def GAMEB_LVL2      equ 2

def GAME_DIFF_THRES equ 10

;;; rPLAYER
def PLAYERF_HIT     equ %10000000
def PLAYERF_HOLD    equ %01000000
def PLAYERF_A       equ %00100000
def PLAYERF_B       equ %00010000
def PLAYERF_FALL    equ %00001000

def PLAYERB_HOLD    equ 6
def PLAYERB_A       equ 5
def PLAYERB_B       equ 4
def PLAYERB_FALL    equ 3

;;; rCOLLISION
def rCOLL_YHIGH     equ %10000000
def rCOLL_YLOW      equ %01000000
def COLLF_XPERF     equ %00100000
def COLLF_XGOOD     equ %00010000
def COLLF_XBAD      equ %00001000
def COLLF_XMISS     equ %00000100
; ^ one of these flags should always be set!

def COLLB_YHIGH     equ 7 ; remove this --> going into spell obj
def COLLB_YLOW      equ 6
def COLLB_XPERF     equ 5
def COLLB_XGOOD     equ 4
def COLLB_XBAD      equ 3
def COLLB_XMISS     equ 2

;;; SPELL OBJ WRAM FlAGS
def SPELLF_HIGH     equ %00000010
def SPELLF_LOW      equ %00000000
def SPELLF_ON       equ %00000001
def SPELLF_OFF      equ %00000000

def SPELLB_TIER     equ 1
def SPELLB_SPAWN    equ 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc