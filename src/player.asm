; 
; CS-240 World 5: Basic Game Functionality
;
; @file player.asm
; @author Sydney Chen, Alfonso Rada
; @brief storing player functions

include "src/hardware.inc"
include "src/utils.inc"
include "src/joypad.inc"
include "src/sprites.inc"
include "src/wram.inc"

section "player", rom0

InitPlayer:
    ; MC.00
    copy [SPRITE_0_ADDRESS + OAMA_Y], 0
    copy [SPRITE_0_ADDRESS + OAMA_X], 0
    copy [SPRITE_0_ADDRESS + OAMA_TILEID], 0
    copy [SPRITE_0_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.01
    copy [SPRITE_1_ADDRESS + OAMA_Y], 0
    copy [SPRITE_1_ADDRESS + OAMA_X], 0
    copy [SPRITE_1_ADDRESS + OAMA_TILEID], 2
    copy [SPRITE_1_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.02
    copy [SPRITE_2_ADDRESS + OAMA_Y], 0
    copy [SPRITE_2_ADDRESS + OAMA_X], 0
    copy [SPRITE_2_ADDRESS + OAMA_TILEID], 4
    copy [SPRITE_2_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.10
    copy [SPRITE_3_ADDRESS + OAMA_Y], 0
    copy [SPRITE_3_ADDRESS + OAMA_X], 0
    copy [SPRITE_3_ADDRESS + OAMA_TILEID], 6
    copy [SPRITE_3_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.11
    copy [SPRITE_4_ADDRESS + OAMA_Y], 0
    copy [SPRITE_4_ADDRESS + OAMA_X], 0
    copy [SPRITE_4_ADDRESS + OAMA_TILEID], 8
    copy [SPRITE_4_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ; MC.12
    copy [SPRITE_5_ADDRESS + OAMA_Y], 0
    copy [SPRITE_5_ADDRESS + OAMA_X], 0
    copy [SPRITE_5_ADDRESS + OAMA_TILEID], 10
    copy [SPRITE_5_ADDRESS + OAMA_FLAGS], OAMF_PAL0

    ret

MovePlayerToStart:
    ; MC.00
    copy [SPRITE_0_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_0_ADDRESS + OAMA_X], 20

    ; MC.01
    copy [SPRITE_1_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_1_ADDRESS + OAMA_X], 28

    ; MC.02
    copy [SPRITE_2_ADDRESS + OAMA_Y], MC_TOP_Y
    copy [SPRITE_2_ADDRESS + OAMA_X], 36

    ; MC.10
    copy [SPRITE_3_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_3_ADDRESS + OAMA_X], 20

    ; MC.11
    copy [SPRITE_4_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_4_ADDRESS + OAMA_X], 28

    ; MC.12
    copy [SPRITE_5_ADDRESS + OAMA_Y], MC_BOT_Y
    copy [SPRITE_5_ADDRESS + OAMA_X], 36

    ret

; put PC sprite ids in WRAM
InitPlayerSpriteData:
    copy16bit [$C010], [$C011], _OAMRAM
    copy16bit [$C012], [$C013], _OAMRAM + sizeof_OAM_ATTRS * 1
    copy16bit [$C014], [$C015], _OAMRAM + sizeof_OAM_ATTRS * 2
    copy16bit [$C016], [$C017], _OAMRAM + sizeof_OAM_ATTRS * 3
    copy16bit [$C018], [$C019], _OAMRAM + sizeof_OAM_ATTRS * 4
    copy16bit [$C01A], [$C01B], _OAMRAM + sizeof_OAM_ATTRS * 5

    ret

Jump:
    ld a, [rPLAYER]
    bit 3, a
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    jr z, .go_up
        ld a, [SPRITE_0_ADDRESS + OAMA_Y]
        add 8
        ld [SPRITE_0_ADDRESS + OAMA_Y], a
        ld [SPRITE_1_ADDRESS + OAMA_Y], a
        ld [SPRITE_2_ADDRESS + OAMA_Y], a
        add $10
        ld [SPRITE_3_ADDRESS + OAMA_Y], a
        ld [SPRITE_4_ADDRESS + OAMA_Y], a
        ld [SPRITE_5_ADDRESS + OAMA_Y], a
        sub $10
        jr .check_thres1

    .go_up
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    ; sprites 0-1-2 and 3-4-5 have same Y respectively - $10 off
    sub 8
    ld [SPRITE_0_ADDRESS + OAMA_Y], a
    ld [SPRITE_1_ADDRESS + OAMA_Y], a
    ld [SPRITE_2_ADDRESS + OAMA_Y], a
    add $10
    ld [SPRITE_3_ADDRESS + OAMA_Y], a
    ld [SPRITE_4_ADDRESS + OAMA_Y], a
    ld [SPRITE_5_ADDRESS + OAMA_Y], a
    sub $10
    
    ; go back down
    .check_thres1
    cp MC_JUMP_THRES
    jr nz, .check_thres2
        ld a, [rPLAYER]
        set 3, a
        ld [rPLAYER], a
        jr .return

    ; go back up
    .check_thres2
    cp MC_TOP_Y
    jr nz, .return
        ld a, [rPLAYER]
        res 3, a
        ld [rPLAYER], a
    
    .return
    ret

PlayerHitHigh:
    ; hit shield
    copy [SPRITE_9_ADDRESS + OAMA_Y], 0
    copy [SPRITE_9_ADDRESS + OAMA_X], 0

    ; if on frame 3, run an additional frame
    ; condition
    ld a, [rGAME]
    bit 6, a ;check for hold anim
    jr nz, .extend_frame
        UpdatePlayerAnim $C010, $C01C, $90 
        jr .end_frame_update
    .extend_frame
        copy [SPRITE_9_ADDRESS + OAMA_Y], MC_TOP_Y + 12
        copy [SPRITE_9_ADDRESS + OAMA_X], 20 + 24
        copy [rGAME], GAME_BASE
    .end_frame_update
    ; frame 3-4: ($60) + set shield visible

    call Jump
    ; may req some pushing/pulling
    ret

PlayerHitLow:
    ; hit shield
    copy [SPRITE_9_ADDRESS + OAMA_Y], 0
    copy [SPRITE_9_ADDRESS + OAMA_X], 0

    ; if on frame 3, run an additional frame
    ld a, [rGAME]
    bit 6, a ;check for hold anim
    jr nz, .extend_frame
        UpdatePlayerAnim $C010, $C01C, $60 ;, $FF; $60
        jr .end_frame_update
    .extend_frame
        copy [SPRITE_9_ADDRESS + OAMA_Y], MC_TOP_Y + 12
        copy [SPRITE_9_ADDRESS + OAMA_X], 20 + 24
        copy [rGAME], GAME_BASE
    .end_frame_update
    ; frame 1: ($40)
    ; frame 2: ($50)
    ; frame 3-4: ($60) + set shield visible
    ret


; problems:
; need b_anim to run in full after pressing b, not just while holding
; - also need b_anim to restart if pressing b again
; - also, [hold] should NOT cause b to run again
; similarly, restructure jump to run frame-by-frame instead of as its own func
; - same issues w/ b_anim
; might need macro to restore run anim sprite addresses after running player anim?
UpdatePlayer:
    halt 
    halt
    halt

    ; joypad flag handling; B
    ld a, [PAD_CURR]
    bit PADB_B, a
    jr nz, .skip_B
        SetRegBit rPLAYER, PLAYERB_B
        copy [rPCA_COUNT], $00 ; lower half
        SetPlayerTiles $30
        ; unset A flag?
    .skip_B
    
    ld a, [PAD_CURR] ;remove once regs preserved?
    bit PADB_A, a
    jr nz, .skip_A
        SetRegBit rPLAYER, PLAYERB_A
        copy [rPCA_COUNT], $00 ; lower half
        SetPlayerTiles $60
        ; unset B flag?
    .skip_A

    ; IF/ELSE -> if A is set, run animA, if B is set run animB, else run Run
    ld a, [rPLAYER]
    bit PLAYERB_B, a
    jr nz, .update_b; .fin_a_update

    bit PLAYERB_A, a
    jr nz, .update_a ; replace

    jr .update_run

    .update_b
    ld a, [rPCA_COUNT]
    cp a, $3
    jr z, .update_a
        SetPlayerY MC_TOP_Y
        call PlayerHitLow

        ld a, [rPCA_COUNT]
        inc a
        ld [rPCA_COUNT], a

        jr .done_update

    .update_a
    cp a, $3
    jr z, .update_run
        call PlayerHitHigh

        ld a, [rPCA_COUNT]
        inc a
        ld [rPCA_COUNT], a

        jr .done_update
    
    .update_run
        ResRegBit rPLAYER, PLAYERB_B
        ResRegBit rPLAYER, PLAYERB_A
    
    ; else,
        ; unset flags, 
        ; reset threshold..? maybe not + leave that to joypad handling
        ; SetPlayerTiles $00 ; may not be needed?


    /*
    ld a, [PAD_CURR]
    bit PADB_A, a
    jr nz, .done_high
        ; SetPlayerTiles $70
        call Jump
        call PlayerHitHigh
        jp .done_update
    .done_high
    
    ld a, [PAD_CURR]
    bit PADB_B, a
    jr nz, .done_low
        call PlayerHitLow
        jr .done_update
    .done_low
    */

        SetPlayerY MC_TOP_Y
        ld a, [rPLAYER]
        res 3, a
        ld [rPLAYER], a

        ; SetPlayerTiles $00 ; don't need this line?
        UpdatePlayerAnim $C010, $C01C, $30 ;, $FF

    .done_update
    ret

;;;;;
export Jump, UpdatePlayer, InitPlayer, InitPlayerSpriteData, MovePlayerToStart