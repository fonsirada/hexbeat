; 
; CS-240 World 8: Your final, polished game
;
; @file wram.inc
; @author Darren Strash, Sydney Chen, Alfonso Rada
; @date April 16, 2025
; @brief a place to store all WRAM variables
; @license

if !def(WRAM_RGBINC)
def WRAM_RGBINC equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "src/hardware.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; JOYPAD HANDLING ;;;
rsset _RAM
def PAD_CURR rb 1
def PAD_PREV rb 1
def PAD_PRSS rb 1
def PAD_RLSE rb 1
def PAD_LHOLD rb 1
def HOLD_A_COUNTER rb 1

;;; ADDITIONAL CUSTOM REGISTERS ;;;
def rGAME            rb 1
def rGAME_DIFF       rb 1
def rPLAYER          rb 1
def rPC_HEALTH       rb 1
def rPC_ACOUNT       rb 1
def rCOLLISION       rb 1
def rTIMER_BG        rb 1
def rTIMER_PC        rb 1
def rTIMER_OBJ       rb 1
def rTIMER_DMG       rb 1
def rSPELL_COUNT     rb 1
def rGAME_LVL        rb 1

;;; SOUND 
rsset (_RAM + $60)
def WRAM_PAD_INPUT                  rb 0
def WRAM_FRAME_COUNTER              rb 1
def WRAM_NOTE_INDEX                 rb 1
def WRAM_END                        rb 0
def rNOTEMAP                        rb 2
def rSONGMAP                        rb 2
def rSONGMAP_LENGTHS                rb 2
def rNOTE_DELAY                     rb 1

;;; rGAME
def GAMEF_BASE       equ %00000000
def GAMEF_START      equ %00000001
def GAMEF_END        equ %00000010
def GAMEF_END_PRINT  equ %00000100
def GAMEF_NOTE_HIT   equ %01000000
def GAMEF_SPAWN      equ %10000000

def GAMEB_START      equ 0
def GAMEB_END        equ 1
def GAMEB_END_PRINT  equ 2
def GAMEB_NOTE_HIT   equ 6
def GAMEB_SPAWN      equ 7

;;; rPLAYER
def PLAYERF_HIT      equ %10000000
def PLAYERF_HOLD     equ %01000000
def PLAYERF_A        equ %00100000
def PLAYERF_B        equ %00010000

def PLAYERB_HOLD     equ 6
def PLAYERB_A        equ 5
def PLAYERB_B        equ 4

;;; rCOLLISION
def rCOLL_YHIGH      equ %10000000
def rCOLL_YLOW       equ %01000000
def COLLF_XPERF      equ %00100000
def COLLF_XGOOD      equ %00010000
def COLLF_XBAD       equ %00001000
def COLLF_XMISS      equ %00000100

def COLLB_YHIGH      equ 7
def COLLB_YLOW       equ 6
def COLLB_XPERF      equ 5
def COLLB_XGOOD      equ 4
def COLLB_XBAD       equ 3
def COLLB_XMISS      equ 2

;;; SPELL OBJ WRAM FlAGS
def SPELLF_HIGH      equ %00000100
def SPELLF_LOW       equ %00000000
def SPELLF_SPAWN     equ %00000010
def SPELLF_NOSPAWN   equ %00000000
def SPELLF_ON        equ %00000001
def SPELLF_OFF       equ %00000000

def SPELLB_TIER      equ 2
def SPELLB_SPAWN     equ 1
def SPELLB_ON        equ 0

; SPELL WRAM
def SPELL_FLAG_START    equ $C020
def SPELL_FLAG_INTERVAL equ 2
def SPELLF_WRAM_OFFSET  equ $20
def SPELL_WRAM_START    equ $C040
def SPELL_WRAM_END      equ $C060

;;; GAME DIFFICULTY
def SPELL_NUM_LVL1          equ low(SPELL_WRAM_END - $10)
def SPELL_NUM_LVL2          equ low(SPELL_WRAM_END - $8)
def SPELL_NUM_LVL3          equ low(SPELL_WRAM_END)
def GAME_DIFF_THRES_LVL2    equ 24
def GAME_DIFF_THRES_BOSSLVL equ 56
def GAME_DIFF_THRES_WIN     equ 96


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endc