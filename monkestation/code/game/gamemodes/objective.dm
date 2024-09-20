/datum/objective/proc/setup_player_target(player)
	var/datum/mind/player_mind = get_mind(target)
	if(player_mind)
		RegisterSignal(player_mind, SIGNAL_ADDTRAIT(TRAIT_CRYOED), PROC_REF(on_target_cryo), override = TRUE)

/datum/objective/proc/unset_player_target(player)
	var/datum/mind/player_mind = get_mind(target)
	if(player_mind)
		UnregisterSignal(player_mind, SIGNAL_ADDTRAIT(TRAIT_CRYOED))

/// Called whenever a specified target cryoes.
/datum/objective/proc/on_target_cryo(datum/mind/source)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	unset_player_target(source)
