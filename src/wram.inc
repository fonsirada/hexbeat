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

;;; ADDITIONAL REGISTERS ;;;
def rGAME           rb 1
def rPLAYER         rb 1
def rPCA_COUNT      rb 1
def rCOLLISION      rb 1
def rTIMER_BG       rb 1
def rTIMER_PC       rb 1
def rTIMER_OBJ      rb 1
def rTIMER_OBJ2     rb 1

;;; rGAME
def GAME_BASE       equ %00000000
def GAME_START      equ %00000001
def GAME_END        equ %00000010

def GAMEB_START     equ 0
def GAMEB_END       equ 1

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
def rCOLL_Y         equ %10000000
; [may want another Y flag here]
def COLLF_XPERF     equ %00100000
def COLLF_XGOOD     equ %00010000
def COLLF_XBAD      equ %00001000
def COLLF_XMISS     equ %00000100
; ^ one of these flags should always be set!

def COLLB_Y         equ 7
def COLLB_XPERF     equ 5
def COLLB_XGOOD     equ 4
def COLLB_XBAD      equ 3
def COLLB_XMISS     equ 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc