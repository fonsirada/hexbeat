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

;;;;; game data?
def rGAME    rb 1
def rPLAYER  rb 1
def rPC_ANIM_COUNTER    rb 1


def GAME_BASE               equ %00000000
def GAME_STARTED            equ %00000001
def GAME_ENDED              equ %00000010
def GAME_A                  equ %00100000
def GAME_B                  equ %00010000

def GAMEB_A                 equ 5
def GAMEB_B                 equ 4
def GAMEB_STARTED           equ 0
def GAMEB_ENDED             equ 1
; outsource below to rPLAYER?

def PLAYERF_HIT                equ %10000000
def PLAYERF_HOLDANIM           equ %01000000
def PLAYERF_A                  equ %00100000
def PLAYERF_B                  equ %00010000
def PLAYERF_FALL               equ %00001000

endc