; 
; CS-240 World 8: Your final, polished game
;
; @file sprites.asm
; @author Sydney Chen, Alfonso Rada
; @date April 24, 2025
; @brief storing non-player sprite functions

include "src/hardware.inc"
include "src/utils.inc"
include "src/wram.inc"
include "src/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "sprites", rom0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def TARGET_HIGH_TILEID     equ $4E
def TARGET_LOW_TILEID      equ $5E
def SHIELD_HIGH_TILEID     equ $6E
def SHIELD_LOW_TILEID      equ $7E
def SPELL1A_TILEID         equ $0E
def SPELL1B_TILEID         equ $1E
def SPELL2A_TILEID         equ $2E
def SPELL2B_TILEID         equ $3E

def SPAWN_DELAY            equ 9 
def SPRITE_MEM_OFFSET      equ $0004
def SPRITE_P2_Y            equ $0003

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NOTE FORMAT:
; $__ __ = $(spawn?)(high/low)
; eg. $0100 = spawn note, spawn low
Mapping:
dw $0100, $0000, $0101, $0000, $0100, $0000, $0101, $0000
dw $0000, $0100, $0101, $0000, $0101, $0101, $0000, $0100
dw $0000

Boss_Level:
dw $0100, $0101, $0101, $0101, $0000, $0100, $0000, $0101
dw $0101, $0000, $0101, $0100, $0100, $0101, $0000, $0100
dw $0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; place sprite locations into WRAM
init_sprite_data:
    call init_player_sprite_data

    ; put spell flags into WRAM
    ld hl, SPELL_FLAG_START
    .load_spell_flag
        ld a, SPELLF_OFF
        ld [hli], a
        ld a, l
        cp a, low(SPELL_WRAM_START)
        jr nz, .load_spell_flag

    ; put spell sprite addresses into WRAM
    ld hl, SPELL_WRAM_START
    Copy16BitVal [hli], [hli], SPRITE_10_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_11_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_12_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_13_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_14_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_15_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_16_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_17_ADDRESS

    ; next 4:
    Copy16BitVal [hli], [hli], SPRITE_18_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_19_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_20_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_21_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_22_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_23_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_24_ADDRESS
    Copy16BitVal [hli], [hli], SPRITE_25_ADDRESS
    
    ret

; initalize sprites and their attributes
; format: sprite #, (x, y), tile ID, palette mode
init_sprites:
    ; TARGETS
    SetSpriteData 6, 0, 0, TARGET_HIGH_TILEID, OAMF_PAL0
    SetSpriteData 7, 0, 0, TARGET_LOW_TILEID, OAMF_PAL0

    ; PLAYER 'SHIELD' SPRITES
    SetSpriteData 8, 0, 0, SHIELD_HIGH_TILEID, OAMF_PAL0
    SetSpriteData 9, 0, 0, SHIELD_LOW_TILEID, OAMF_PAL0

    ; SPELL OBJ SPRITES
    SetSpriteData 10, 0, 0, SPELL1A_TILEID, OAMF_PAL0
    SetSpriteData 11, 0, 0, SPELL1B_TILEID, OAMF_PAL0

    SetSpriteData 12, 0, 0, SPELL2A_TILEID, OAMF_PAL0
    SetSpriteData 13, 0, 0, SPELL2B_TILEID, OAMF_PAL0

    SetSpriteData 14, 0, 0, SPELL1A_TILEID, OAMF_PAL0
    SetSpriteData 15, 0, 0, SPELL1B_TILEID, OAMF_PAL0

    SetSpriteData 16, 0, 0, SPELL2A_TILEID, OAMF_PAL0
    SetSpriteData 17, 0, 0, SPELL2B_TILEID, OAMF_PAL0

    ret

; init level 1 targets & two spells
init_level_1:
    ; TARGETS
    SetSpriteXY 6, TARGET_X, TARGET_HIGH_Y
    SetSpriteXY 7, TARGET_X, TARGET_LOW_Y

    ; SPELL OBJs
    SetSpriteXY 10, SPELL_SPAWNX, SPELL_HIGH_Y
    SetSpriteXY 11, SPELL_SPAWNX, SPELL_HIGH_Y
    SetSpriteXY 12, SPELL_SPAWNX, SPELL_LOW_Y
    SetSpriteXY 13, SPELL_SPAWNX, SPELL_LOW_Y
    ret

; init level 3's spells (+2)
init_level_3:
    ld a, high(Boss_Level)
    ld [WRAM_NOTEMAP], a
    ld a, low(Boss_Level)
    ld [WRAM_NOTEMAP], a
    ld [WRAM_NOTEMAP + 1], a

    halt 
    copy [rSPELL_COUNT], BOSSLVL_SPELL_NUM
    SetSpriteXY 14, SPELL_SPAWNX, SPELL_HIGH_Y
    SetSpriteXY 15, SPELL_SPAWNX, SPELL_HIGH_Y
    SetSpriteXY 16, SPELL_SPAWNX, SPELL_LOW_Y
    SetSpriteXY 17, SPELL_SPAWNX, SPELL_LOW_Y
    ret

; loops thru all active sprites in WRAM and updates them
; NOTE: returns hl and d for handle_collision and handle_miss
; working ver w/ new sprite system
update_sprites:
    CheckTimer rTIMER_OBJ, 1
    jr nz, .done_update

    ld hl, SPELL_WRAM_START
    .update_spell_sprite
        ; preserve OG WRAM address 
        push hl
        
        ; get flags in (d) and address in (hl)
        GetSpriteFlags d
        WRAMToOAM bc

        ; SPELL OFF/ON
        bit SPELLB_ON, d
        jr nz, .spell_on
            
        ; ---- IF SPELL IS OFF... ---- ;
            ; HANDLE SPELL SPAWNING ;
            call check_spawn
            bit SPELLB_SPAWN, d
            jr z, .skip_spawn
                call spawn_spell
                ld a, d
                xor a, SPELLF_ON | SPELLF_SPAWN
                ld d, a
            .skip_spawn
            jr .to_next_sprite

        ; ---- IF SPELL IS ON... ---- ;
        .spell_on
        ; SPELL MOVEMENT ;
        ; update sprite pt 1
        ; get sprite pt 1's x val address
        ld bc, ($0000 + OAMA_X)
        add hl, bc
        push hl
        ld a, [hl]

            ; HANDLE SPELL DESPAWNING ;
            cp a, DMG_THRES
            jr nc, .update_x_movement
                ; unflag ON
                ld a, d
                xor a, SPELLF_ON
                ld d, a
                
                ; set y-val to 0
                dec hl
                ld [hl], 0
                
                ld bc, SPRITE_MEM_OFFSET
                add hl, bc
                ld [hl], 0
                
                pop hl
                jr .to_next_sprite
                
        .update_x_movement
        ; update sprite pt 1's x val
        sub SPELL_SCROLL_SPEED
        ld [hl], a

        dec hl
        ld e, [hl]
        inc hl

        ; update sprite pt 2's y val
        ld bc, SPRITE_P2_Y
        add hl, bc
        ld [hl], e
        
        ; update sprite pt 2's x val
        add a, OBJ16_OFFSET
        inc hl
        ld [hl], a

        pop hl

        ; SPELL COLLISION ;
        ; need sprite x-val address in (hl)
        bit SPELLB_ON, d
        jr z, .to_next_sprite
            call check_collisions

        .to_next_sprite
        ; restore and move to next WRAM loc
        pop hl
        SetSpriteFlags d
        ld bc, SPRITE_MEM_OFFSET
        add hl, bc

        ld a, [rSPELL_COUNT]
        cp a, l
        jr nz, .update_spell_sprite
    .done_update
    RegBitOp rGAME, GAMEB_SPAWN, res
    ret

; check if the given spell obj in (hl) has been hit 
check_collisions:
    ; clear flags and raise miss flag
    copy [rCOLLISION], COLLF_XMISS

    ; check where the current x is & set rCOLLISION flags
    CheckSpriteRange [hl], HIT_PERF_MIN, HIT_PERF_MAX, COLLB_XPERF
    CheckSpriteRange [hl], HIT_GOOD_MIN, HIT_GOOD_MAX, COLLB_XGOOD
    CheckSpriteRange [hl], HIT_BAD_MIN, HIT_BAD_MAX, COLLB_XBAD
    CheckSpriteRange [hl], HIT_MISS_MIN, HIT_MISS_MAX, COLLB_XMISS

    ; if B pressed & obj low, try collision
    ld a, [PAD_PRSS]
    bit PADB_B, a
    jr nz, .check_A
        ; get to Y attr in OAM
        dec hl
        ld a, [hl]
        inc hl

        cp a, SPELL_LOW_Y
        jr nz, .check_miss
            jr .run_check
    
    ; if A pressed & obj high, try collision
    .check_A
    bit PADB_A, a
    jr nz, .check_miss
        dec hl
        ld a, [hl]
        inc hl

        cp a, SPELL_HIGH_Y
        jr nz, .check_miss

    .run_check
        ld a, [rCOLLISION]
        bit COLLB_XPERF, a
        jr z, .check_good
            call handle_collision
            jr .done_check

        .check_good
        bit COLLB_XGOOD, a
        jr z, .check_bad
            ; currently, don't hit OR lose health ("free" input buffer)
            jr .done_check

        .check_bad
        bit COLLB_XBAD, a
        jr z, .check_miss
            call handle_bad_collision
            jr .done_check
    
    .check_miss
        call handle_miss
    .done_check
    ret

; runs if player successfully hits a note
; resets the sprite x value
; note: only called in check_collisions
handle_collision:
    ; set off flag
    ld a, d
    res SPELLB_ON, d
    ld d, a

    ; set x val to 0
    ld a, 0
    ld [hl], a
    ld bc, SPRITE_MEM_OFFSET
    add hl, bc
    ld [hl], a

    ; increase game diff counter
    ld a, [rGAME_DIFF]
    inc a
    ld [rGAME_DIFF], a

    ret

; handle collision w/ bad timing
handle_bad_collision:
    ; set off flag
    ld a, d
    res SPELLB_ON, d
    ld d, a

    ; set x val to 0
    ld a, 0
    ld [hl], a
    ld bc, SPRITE_MEM_OFFSET
    add hl, bc
    ld [hl], a

    ; decrease health
    ld a, [rPC_HEALTH]
    dec a
    ld [rPC_HEALTH], a
    
    ; start player flash
    ld a, PC_DMG_COUNT
    ld [rTIMER_DMG], a
    .done
    ret

; runs if the player misses a note
handle_miss:
    ld a, [hl]
    cp a, DMG_THRES
    jr nc, .done
        ; start player flash
        ld a, PC_DMG_COUNT
        ld [rTIMER_DMG], a

        ; lower player health
        ld a, [rPC_HEALTH]
        dec a
        ld [rPC_HEALTH], a
    .done
    ret

; check if a given note should be spawned based on the music
check_spawn:
    push hl

    ld a, [WRAM_FRAME_COUNTER]
    xor a, SPAWN_DELAY
    jr nz, .done_spawn
        ld a, [rGAME]
        bit GAMEB_SPAWN, a
        jr nz, .done_spawn
            ;; SET SPELL OBJ FLAGS ;;
            ; get first note
            ld a, [WRAM_NOTE_INDEX]
            sla a
            ld b, 0
            ld c, a
    
            ; load note + note index
            ld a, [rGAME]
            bit GAMEB_BOSSLVL, a
            jr z, .load_map
                ld a, [WRAM_NOTEMAP]
                ld h, a
                ld a, [WRAM_NOTEMAP + 1]
                ld l, a
                jr .get_note
            .load_map
                ld hl, Mapping
            .get_note
            add hl, bc

            ;; SET OBJ FLAGS ;;
            ; if a = 1, set spawn low
            ld a, [hli]
            xor a, $00
            jr nz, .check_length
                ld a, d
                xor a, SPELLF_HIGH
                ld d, a
            .check_length
            ld a, [hl]
            xor a, $00
            jr z, .load_flags
                set SPELLB_SPAWN, d
                ld a, [rGAME]
                set GAMEB_SPAWN, a
                ld [rGAME], a
            
            ;; LOAD NEW SET OF FLAGS ;;
            .load_flags
            ; to-do...?
    .done_spawn
    pop hl
    ret

; spawns a high/low spell based on its flag attributes
spawn_spell:
    push hl
    bit SPELLB_TIER, d
    jr z, .set_low
        ld [hl], SPELL_HIGH_Y
        jr .set_x
    .set_low
        ld [hl], SPELL_LOW_Y
    .set_x
    inc hl
    ld [hl], SPELL_SPAWNX

    ; set tile ID
    inc hl
    ld bc, SPRITE_MEM_OFFSET
    bit SPELLB_TIER, d
    jr z, .set_low_id
        ld [hl], SPELL1A_TILEID
        add hl, bc
        ld [hl], SPELL1B_TILEID
        jr .set_flags
    .set_low_id
        ld [hl], SPELL2A_TILEID
        add hl, bc
        ld [hl], SPELL2B_TILEID

    .set_flags
    inc hl
    ld [hl], OAMF_PAL0

    pop hl
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sprite_data, init_sprites, init_level_1, init_level_3, update_sprites