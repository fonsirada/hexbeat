; 
; CS-240 World 6: Fully functional draft
;
; @file sprites.asm
; @author Sydney Chen, Alfonso Rada
; @date April 16, 2025
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

def SPELL1_SPAWNX          equ 168
def SPELL2_SPAWNX          equ 120
def SPELL3_SPAWNX          equ 120
def SPELL4_SPAWNX          equ 168

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; place sprite locations into WRAM
init_sprite_data:
    call init_player_sprite_data

    ; put spell flags into WRAM
    ld hl, SPELL_FLAG_START
    .load_spell_flag
        ld a, SPELLF_ON;%00000001;0
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
    SetSpriteXY 10, SPELL1_SPAWNX, SPELL_HIGH_Y
    SetSpriteXY 11, SPELL1_SPAWNX, SPELL_HIGH_Y
    SetSpriteXY 12, SPELL2_SPAWNX, SPELL_LOW_Y
    SetSpriteXY 13, SPELL2_SPAWNX, SPELL_LOW_Y
    ret

; check if the level 2 threshold is passed
check_level_2:
    ld a, [rGAME_DIFF]
    cp a, GAME_DIFF_THRES
    jr nz, .done_check
        ld a, [rGAME]
        bit GAMEB_LVL2, a
        jr nz, .done_check
            call init_level_2
            RegBitOp rGAME, GAMEB_LVL2, set
    .done_check
    ret

; init level 2's spells (+2)
init_level_2:
    halt
    copy [rSPELL_COUNT], LVL2_SPELL_NUM
    SetSpriteXY 14, SPELL3_SPAWNX, SPELL_HIGH_Y
    SetSpriteXY 15, SPELL3_SPAWNX, SPELL_HIGH_Y
    SetSpriteXY 16, SPELL4_SPAWNX, SPELL_LOW_Y
    SetSpriteXY 17, SPELL4_SPAWNX, SPELL_LOW_Y
    ret

; loops thru all active sprites in WRAM and updates them
; NOTE: returns hl and de for handle_collision and handle_miss
update_sprites:
    push hl

    CheckTimer rTIMER_OBJ, 1
    jr nz, .done_update

    ld hl, SPELL_WRAM_START
    .update_spell_sprite
        ; preserve hl and store in de
        push hl
        ld d, h
        ld e, l

        ; load spell_a address into (hl)
        WRAMToOAM bc
        ld b, $00
        ld c, OAMA_X
        add hl, bc

        ; preserve pt 1
        push hl

        ;CheckTimer rTIMER_OBJ, 1
        ;jr nz, .done_anim_update
        ; putting above here fixes input drops, but
        ; has issues w/ health updating...
            ; load in new x val
            ld a, [hl]
            sub SPELL_SCROLL_SPEED
            ld [hl], a

            ; load spell_b address into (hl)
            ld h, d
            ld l, e
            inc hl
            inc hl
            WRAMToOAM bc
            ld b, $00
            ld c, OAMA_X
            add hl, bc

            ; load offset x val for sprite pt 2
            add a, OBJ16_OFFSET
            ld [hl], a

        .done_anim_update
        ; preserve sprite pt 2
        push hl

        ; get 2nd sprite part
        pop hl
        ld d, h
        ld e, l

        ; get 1st sprite part
        pop hl
        call check_collisions

        ; to next spell sprite (in WRAM)
        pop hl
        inc hl
        inc hl
        inc hl
        inc hl
        
        ld a, [rSPELL_COUNT]
        cp a, l
        jr nz, .update_spell_sprite

    ;SetShieldLocations 0, 0, 0, 0 ; moved to update_player
    .done_update
    pop hl

    ret

; working ver w/ new sprite system
update_sprites2:
    CheckTimer rTIMER_OBJ, 1
    jr nz, .done_update

    ld hl, SPELL_WRAM_START
    .update_spell_sprite
        ;;;;;;; TO DO ;;;;;;;;;
        ; in this loop, per sprite:
        ; if spawn = 1, spawn sprite & reset flag

        ; - BUG: dmg triggers twice - FIXED
        ; - BUG: spawn flag weirdness - FIXED

        ; NOTE: for testing, see CheckSpawn macro
        ;;;;;;;;;;;;;;;;;;;;;;;

        ; preserve OG WRAM address 
        push hl
        
        ; get flags in (d) and address in (hl)
        GetSpriteFlags d
        WRAMToOAM bc

        ; SPELL OFF/ON
        bit SPELLB_ON, d
        jr nz, .spell_on
            
        ; ---- SPELL IS OFF... ---- ;
            ; HANDLE SPELL SPAWNING ;
            CheckSpawn d
            bit SPELLB_SPAWN, d
            jr z, .skip_spawn
                SpawnSpell d
                ld a, d
                xor a, SPELLF_ON | SPELLF_SPAWN
                ld d, a
            .skip_spawn
            jr .to_next_sprite


        ; ---- SPELL IS ON... ---- ;
        .spell_on
        ; SPELL MOVEMENT ;
        ; update sprite pt 1
        ; get sprite pt 1's x val address
        ld bc, ($0000 + OAMA_X)
        add hl, bc
        push hl
        ld a, [hl]

            ; HANDLE SPELL DESPAWNING ;
            ; if x < 2:
            cp a, DMG_THRES;2
            jr nc, .update_x_movement
                ; unflag ON
                ld a, d
                xor a, SPELLF_ON
                ld d, a
                
                ; set y-val to 0
                dec hl
                ld [hl], 0
                
                ld bc, ($0004) ; sprite memory offset
                add hl, bc
                ld [hl], 0
                
                pop hl ; matches w/ spell movement push
                jr .to_next_sprite
                
        .update_x_movement
        ; update sprite pt 1's x val
        sub SPELL_SCROLL_SPEED
        ld [hl], a

        dec hl
        ld e, [hl]
        inc hl

        ; update sprite pt 2's y val
        ld bc, ($0003)
        add hl, bc
        ld [hl], e
        
        ; update sprite pt 2's x val
        add a, OBJ16_OFFSET
        inc hl
        ld [hl], a

        pop hl

        ; SPELL COLLISION
        ; need sprite x-val address in (hl)
        bit SPELLB_ON, d
        jr z, .to_next_sprite
            call check_collisions

        .to_next_sprite
        ; restore and move to next WRAM loc
        pop hl
        SetSpriteFlags d
        ld bc, ($0004) ; sprite memory offset
        add hl, bc ; note: this add method is 1 cycle faster than inc-ing

        ld a, [rSPELL_COUNT]
        cp a, l
        jr nz, .update_spell_sprite
    .done_update
    ;SetShieldLocations 0, 0, 0, 0 
    ret

; check if the given spell obj in (hl) has been hit 
check_collisions:
    ; clear flags and raise miss flag
    copy [rCOLLISION], COLLF_XMISS

    ; check if the current x is within the 'perfect' x range
    CheckSpriteRange [hl]

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
        jr z, .check_miss
            call handle_collision
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
    ld bc, $0004 ; try de if being weird
    add hl, bc
    ld [hl], a

    ; increase game diff counter
    ld a, [rGAME_DIFF]
    inc a
    ld [rGAME_DIFF], a
    ret

; runs if the player misses a note
handle_miss:
    ld a, [hl]
    cp a, DMG_THRES
    jr nc, .done
    ;jr nc, .done
        ; lower player health
        ld a, [rPC_HEALTH]
        dec a
        ld [rPC_HEALTH], a

        ; if health is 0, raise game_end flag
        cp a, 0
        jr nz, .done
            RegBitOp rGAME, GAMEB_END, set
    .done
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

export init_sprite_data, init_sprites, init_level_1, check_level_2, update_sprites, update_sprites2