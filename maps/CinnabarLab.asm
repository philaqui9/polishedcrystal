const_value set 2
	const CINNABARLAB_GIOVANNI
	const CINNABARLAB_MEWTWO
	const CINNABARLAB_SCIENTIST1
	const CINNABARLAB_SCIENTIST2

CinnabarLab_MapScriptHeader:
.MapTriggers:
	db 2

	; triggers
	maptrigger .Trigger0
	maptrigger .Trigger1

.MapCallbacks:
	db 0

.Trigger0:
	priorityjump CinnabarLabStepDownScript
	end

.Trigger1:
	end

CinnabarLabStepDownScript:
	checkcode VAR_YCOORD
	if_not_equal $6, .Done
	checkcode VAR_XCOORD
	if_not_equal $2, .Done
	applymovement PLAYER, CinnabarLabStepDownMovementData
.Done
	dotrigger $1
	end

CinnabarLabCelebiEventScript:
	playsound SFX_EXIT_BUILDING
	special FadeOutPalettes
	pause 15
	dotrigger $0
	warpfacing UP, CINNABAR_LAB, $f, $9
	special Special_FadeOutMusic
	pause 30
	opentext
	writetext CinnabarLabContinueTestingText
	waitbutton
	closetext
	showemote EMOTE_SHOCK, CINNABARLAB_GIOVANNI, 15
	playmusic MUSIC_ROCKET_OVERTURE
	spriteface CINNABARLAB_GIOVANNI, DOWN
	opentext
	writetext CinnabarLabGiovanniWhoAreYouText
	waitbutton
	closetext
	applymovement CINNABARLAB_GIOVANNI, CinnabarLabGiovanniStepAsideMovementData
	applymovement PLAYER, CinnabarLabPlayerStepsUpMovementData
	opentext
	writetext CinnabarLabGiovanniAttackText
	cry MEWTWO
	waitsfx
	closetext
	winlosstext CinnabarLabGiovanniBeatenText, 0
	setlasttalked CINNABARLAB_GIOVANNI
	loadtrainer GIOVANNI, 2
	startbattle
	reloadmapafterbattle
	end

CinnabarLabRoom1Sign:
	jumptext CinnabarLabRoom1SignText

CinnabarLabRoom2Sign:
	jumptext CinnabarLabRoom2SignText

CinnabarLabRoom3Sign:
	jumptext CinnabarLabRoom3SignText

CinnabarLabRoom4Sign:
	jumptext CinnabarLabRoom4SignText

CinnabarLabStepDownMovementData:
	step_down
	step_end

CinnabarLabGiovanniStepAsideMovementData:
	turn_head_left
	fix_facing
	slow_step_right
	slow_step_right
	remove_fixed_facing
	step_end

CinnabarLabPlayerStepsUpMovementData:
	slow_step_up
	slow_step_up
	step_end

CinnabarLabLockedDoorSign:
	jumptext CinnabarLabLockedDoorText

CinnabarLabRoom1SignText:
	text "Cloning"
	line "Dept."
	done

CinnabarLabRoom2SignText:
	text "Cybernetics"
	line "Dept."
	done

CinnabarLabRoom3SignText:
	text "Storage"
	done

CinnabarLabRoom4SignText:
	text "Project Amber"
	line "Testing Area"

	para "ABSOLUTELY NO"
	line "ENTRY WITHOUT"
	cont "LEVEL 5 CLEARANCE"
	done

CinnabarLabLockedDoorText:
	text "It's locked…"
	done

CinnabarLabContinueTestingText:
	text "Continue the"
	line "tests. Your"

	para "creation has per-"
	line "formed very well"
	cont "so far, Dr.Fu--"
	done

CinnabarLabGiovanniWhoAreYouText:
	text "Who are you?!"
	line "You aren't part"
	cont "of Team Rocket."

	para "Are you a spy for"
	line "the police?"

	para "…Fine. You want to"
	line "know about Team"
	cont "Rocket's business?"
	cont "I'll show you."

	para "The world's most"
	line "powerful #mon…"
	done

CinnabarLabGiovanniAttackText:
	text "Giovanni: Attack!"
	done

CinnabarLabGiovanniBeatenText:
	text "Giovanni: What?!"
	line "Impossible!"
	done

CinnabarLab_MapEventHeader:
	; filler
	db 0, 0

.Warps:
	db 0
;	warp_def $9, $e, 3, CINNABAR_LAB
;	warp_def $9, $f, 3, CINNABAR_LAB
;	warp_def $6, $2, 2, CINNABAR_LAB

.XYTriggers:
	db 1
	xy_trigger 1, $6, $2, $0, CinnabarLabCelebiEventScript, $0, $0

.Signposts:
	db 7
	signpost 14, 8, SIGNPOST_READ, CinnabarLabRoom1Sign
	signpost 14, 9, SIGNPOST_READ, CinnabarLabLockedDoorSign
	signpost 14, 16, SIGNPOST_READ, CinnabarLabRoom2Sign
	signpost 14, 17, SIGNPOST_READ, CinnabarLabLockedDoorSign
	signpost 14, 24, SIGNPOST_READ, CinnabarLabRoom3Sign
	signpost 14, 25, SIGNPOST_READ, CinnabarLabLockedDoorSign
	signpost 6, 3, SIGNPOST_READ, CinnabarLabRoom4Sign

.PersonEvents:
	db 4
	person_event SPRITE_GIOVANNI, 6, 15, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, ObjectEvent, -1
	person_event SPRITE_MEWTWO, 4, 15, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, (1 << 3) | PAL_OW_PURPLE, PERSONTYPE_SCRIPT, 0, ObjectEvent, -1
	person_event SPRITE_SCIENTIST, 6, 11, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, ObjectEvent, -1
	person_event SPRITE_SCIENTIST, 5, 20, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, ObjectEvent, -1
