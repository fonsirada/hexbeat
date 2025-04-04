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
def sizeof_PAD rb 0

endc