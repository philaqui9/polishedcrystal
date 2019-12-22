FarChangeStat:
; b contains stat to alter, or -1 if it should be read from the move script
	push af
	ld a, 2
	ld [wFailedMessage], a
	ld a, b
	inc b
	jr nz, .move_script_byte_ok
	farcall ReadMoveScriptByte
.move_script_byte_ok
	ld [wLoweredStat], a
	pop af
	ld b, a

	; check attack missing
	bit STAT_MISS_F, b
	jr z, .no_miss
	ld a, [wAttackMissed]
	and a
	jr z, .no_miss

	; The attack missed
	bit STAT_SILENT_F, b
	ret nz
	farcall CheckAlreadyExecuted
	ret nz
	farcall AnimateFailedMove
	ld hl, AttackMissedText
	jp StdBattleTextBox

.no_miss
	; check secondary
	bit STAT_SECONDARY_F, b
	jr z, .no_secondary
	ld a, [wEffectFailed]
	and a
	ret nz

.no_secondary
	; Do target-only checks
	bit STAT_TARGET_F, b
	jr nz, .is_target
	ld a, BATTLE_VARS_ABILITY
	call GetBattleVar
	cp CONTRARY
	jp nz, .ability_done
	ld a, b
	xor STAT_LOWER
	ld b, a
	jp .ability_done

.is_target
	call GetOpponentAbilityAfterMoldBreaker
	cp CONTRARY
	jr nz, .no_target_contrary
	ld a, b
	xor STAT_LOWER
	ld b, a
.no_target_contrary
	push bc
	farcall CheckSubstituteOpp
	pop bc
	jr z, .check_lowering

	bit STAT_SILENT_F, b
	ret nz
	farcall ShowPotentialAbilityActivation
	farcall CheckAlreadyExecuted
	ret nz
	farcall AnimateFailedMove
	farjp PrintButItFailed

.check_lowering
	bit STAT_LOWER_F, b
	jr nz, .ability_done
	ld a, BATTLE_VARS_SUBSTATUS4_OPP
	call GetBattleVar
	bit SUBSTATUS_MIST, a
	jr z, .check_ability
	bit STAT_SILENT_F, b
	ret nz
	farcall CheckAlreadyExecuted
	ret nz
	farcall ShowPotentialAbilityActivation
	farcall AnimateFailedMove
	ld hl, ProtectedByMistText
	jp StdBattleTextBox

.check_ability
	call GetOpponentAbilityAfterMoldBreaker
	cp CLEAR_BODY
	jr z, .ability_immune
	cp HYPER_CUTTER
	ld c, ATTACK
	jr z, .ability_check
	cp BIG_PECKS
	ld c, DEFENSE
	jr z, .ability_check
	cp KEEN_EYE
	ld c, ACCURACY
	jr nz, .ability_done
.ability_check
	ld a, [wLoweredStat]
	and $f
	cp c
	jr nz, .ability_done
.ability_immune
	bit STAT_SILENT_F, b
	ret nz
	farcall CheckAlreadyExecuted
	ret nz
	farcall ShowPotentialAbilityActivation
	farcall AnimateFailedMove
	farcall ShowEnemyAbilityActivation
	ld hl, DoesntAffectText
	jp StdBattleTextBox

.ability_done
	bit STAT_TARGET_F, b
	call nz, SwitchTurn
	push bc
	bit STAT_LOWER_F, b
	jr nz, .lower
	call DoRaiseStat
	jr .stat_done
.lower
	call DoLowerStat
.stat_done
	ld a, [wLoweredStat]
	and $f
	ld b, a
	inc b
	farcall GetStatName
	pop bc
	bit STAT_TARGET_F, b
	call nz, SwitchTurn
	ld a, [wFailedMessage]
	and a
	jr z, .check_anim
	bit STAT_SILENT_F, b
	ret nz
	push bc
	farcall ShowPotentialAbilityActivation
	ld c, 60
	call DelayFrames
	pop bc
	ld hl, WontRiseAnymoreText
	ld de, WontDropAnymoreText
	or 1
	jp .print

.check_anim
	bit STAT_SKIPTEXT_F, b
	ret nz
	bit STAT_SILENT_F, b
	push bc
	jr nz, .anim_done
	farcall TryAnimateCurrentMove
.anim_done
	farcall ShowPotentialAbilityActivation
	pop bc
	ld a, [wLoweredStat]
	and $f0
	swap a
	and a
	ld hl, StatRoseText
	ld de, StatFellText
	jr z, .print
	dec a
	ld hl, StatRoseSharplyText
	ld de, StatHarshlyFellText
	jr z, .print
	ld hl, StatRoseDrasticallyText
	ld de, StatSeverelyFellText
	xor a
.print
	bit STAT_TARGET_F, b
	jr z, .do_print
	push af
	call SwitchTurn
	pop af
	call .do_print
	jp SwitchTurn

.do_print
	bit STAT_LOWER_F, b
	jr z, .printmsg
	ld h, d
	ld l, e
	push af
	push bc
	call StdBattleTextBox
	pop bc
	pop af
	bit STAT_TARGET_F, b
	ret z
	and a
	ret nz
	ld a, [wFailedMessage]
	push af
	farcall RunStatIncreaseAbilities
	pop af
	ld [wFailedMessage], a
	ret

.printmsg
	jp StdBattleTextBox

UseStatItemText:
; doesn't consume the item in case of multiple stats
	push bc
	ld a, [wLoweredStat]
	and $f
	ld b, a
	inc b
	farcall GetStatName
	farcall CheckAlreadyExecuted
	jr nz, .item_anim_done
	farcall ItemRecoveryAnim
.item_anim_done
	ld a, [wLoweredStat]
	and $f0
	swap a
	and a
	ld hl, BattleText_ItemRaised
	ld de, BattleText_ItemLowered
	jr z, .gotmsg
	dec a
	ld hl, BattleText_ItemSharplyRaised
	ld de, BattleText_ItemHarshlyLowered
	jr z, .gotmsg
	ld hl, BattleText_ItemDrasticallyRaised
	ld de, BattleText_ItemSeverelyLowered
.gotmsg
	bit STAT_LOWER_F, b
	jr z, .print
	ld h, d
	ld l, e

.print
	pop bc
	jp StdBattleTextBox

DoLowerStat:
	or 1
	jr DoChangeStat
DoRaiseStat:
	xor a
DoChangeStat:
	push af
	xor a
	ld [wFailedMessage], a
	ld a, [hBattleTurn]
	and a
	ld hl, wPlayerStatLevels
	jr z, .got_stat_levels
	ld hl, wEnemyStatLevels
.got_stat_levels
	ld a, [wLoweredStat]
	and $f
	ld c, a
	ld b, 0
	add hl, bc

	; Perform the stat change
	ld a, [wLoweredStat]
	and $f0
	swap a
	inc a
	ld c, a
	pop af
	jr nz, .lower_loop

.raise_loop
	ld a, [hl]
	cp MAX_STAT_LEVEL
	jr z, .stat_change_done
	inc [hl]
	inc b
	dec c
	jr nz, .raise_loop
	jr .stat_change_done

.lower_loop
	ld a, [hl]
	dec a
	jr z, .stat_change_done
	dec [hl]
	inc b
	dec c
	jr nz, .lower_loop

.stat_change_done
	; Amount of stat levels changed is in b
	ld a, b
	and a
	jr z, .stat_change_failed
	dec b
	swap b
	ld a, [wLoweredStat]
	and $f
	or b
	ld [wLoweredStat], a
	ret

.stat_change_failed
	ld a, 1
	ld [wFailedMessage], a
	ret
