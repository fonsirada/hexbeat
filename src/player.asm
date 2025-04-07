; insert header

include "src/hardware.inc"
include "src/utils.inc"
include "src/joypad.inc"
include "src/sprites.inc"

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
    ; sprites 0 1 2 and 3 4 5 have same Y respectively - $10 off
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    ld b, 16
    .go_up
        dec a
        dec a
        halt
        ld [SPRITE_0_ADDRESS + OAMA_Y], a
        ld [SPRITE_1_ADDRESS + OAMA_Y], a
        ld [SPRITE_2_ADDRESS + OAMA_Y], a
        add $10
        ld [SPRITE_3_ADDRESS + OAMA_Y], a
        ld [SPRITE_4_ADDRESS + OAMA_Y], a
        ld [SPRITE_5_ADDRESS + OAMA_Y], a
        sub $10
        dec b
        jr nz, .go_up
    
    ld b, 16
    .go_down
        inc a
        inc a
        halt 
        ld [SPRITE_0_ADDRESS + OAMA_Y], a
        ld [SPRITE_1_ADDRESS + OAMA_Y], a
        ld [SPRITE_2_ADDRESS + OAMA_Y], a
        add $10
        ld [SPRITE_3_ADDRESS + OAMA_Y], a
        ld [SPRITE_4_ADDRESS + OAMA_Y], a
        ld [SPRITE_5_ADDRESS + OAMA_Y], a
        sub $10
        dec b
        jr nz, .go_down
    
    ret

PlayerHitHigh:
    ; copy [rGAME], GAME_B

    ; hit shield
    copy [SPRITE_9_ADDRESS + OAMA_Y], 0
    copy [SPRITE_9_ADDRESS + OAMA_X], 0

    ; if on frame 3, run an additional frame
    ; condition
    ld a, [rGAME]
    bit 6, a ;check for hold anim
    jr nz, .extend_frame
        UpdatePlayerAnim $C010, $C01C, $90 ;, $FF; $60

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


PlayerHitLow:
    ; copy [rGAME], GAME_B

    ; hit shield
    copy [SPRITE_9_ADDRESS + OAMA_Y], 0
    copy [SPRITE_9_ADDRESS + OAMA_X], 0

    ; if on frame 3, run an additional frame
    ; condition
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

HandleJoypad:
    ; uhhh trying a diff thing for now...
    /*
    ld a, [PAD_CURR]
    bit PADB_B, a
    jr nz, .skip_check
    ld a, [rGAME]
        set GAMEB_B, a
        

    bit PADB_A, a
        set GAMEB_A, a
    */
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

    /*
    ; joypad flag handling; broken rn :(
    ld a, [PAD_CURR]
    bit PADB_B, a
    ld a, [rGAME]
    
    
    ld a, [rGAME]
    bit 4, a
    */

    ; add dual AB press condition here?

    ld a, [PAD_CURR]
    bit PADB_A, a
    jr nz, .done_high
        call PlayerHitHigh
        jr .done_update
    .done_high

    ld a, [PAD_CURR]
    bit PADB_B, a
    jr nz, .done_low
        call PlayerHitLow
        jr .done_update
    .done_low
        UpdatePlayerAnim $C010, $C01C, $30 ;, $FF

    .done_update
    ret

;;;;;
export Jump, UpdatePlayer, InitPlayer, InitPlayerSpriteData, MovePlayerToStart