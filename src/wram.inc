; 
; CS 240: Storing Joypad state, including pressed/released/etc
;
; @file wram.inc
; @author Darren Strash and CS 240
; @brief a place to store all WRAM variables

if !def(WRAM_RGBINC)
def WRAM_RGBINC equ 1

rsset $C000 ; was _RAM from hardware.inc but using magic number just to compile
def PAD_CURR rb 1
def PAD_PREV rb 1
def PAD_PRSS rb 1
def PAD_RLSE rb 1

;;; ADDITIONAL REGISTERS
def rGAME               rb 1
def rPLAYER             rb 1
def rPCA_COUNT          rb 1

;;; rGAME
def GAME_BASE               equ %00000000
def GAME_START              equ %00000001
def GAME_END                equ %00000010

def GAMEB_START             equ 0
def GAMEB_END               equ 1

;;; rPLAYER
def PLAYERF_HIT                equ %10000000
def PLAYERF_HOLD               equ %01000000
def PLAYERF_A                  equ %00100000
def PLAYERF_B                  equ %00010000
def PLAYERF_FALL               equ %00001000

def PLAYERB_HOLD            equ 6
def PLAYERB_A               equ 5
def PLAYERB_B               equ 4
def PLAYERB_FALL            equ 3

endc