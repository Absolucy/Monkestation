/datum/meta_token_holder/proc/approve_antag_token()
	if(!in_queue)
		return

	to_chat(owner, span_boldnicegreen("Your request to play as [in_queue] has been approved."))
	logger.Log(LOG_CATEGORY_META, "[key_name(owner)]'s antag token for [in_queue] has been approved")
	spend_antag_token(in_queued_tier, queued_donor)
	if(!owner.mob.mind)
		owner.mob.mind_initialize()
	in_queue.antag_token(owner.mob.mind, owner.mob) //might not be in queue

	QDEL_NULL(in_queue)
	in_queued_tier = null
	queued_donor = FALSE
	if(antag_timeout)
		deltimer(antag_timeout)
		antag_timeout = null

/datum/meta_token_holder/proc/reject_antag_token()
	if(!in_queue)
		return
	to_chat(owner, span_boldwarning("Your request to play as [in_queue] has been denied."))
	logger.Log(LOG_CATEGORY_META, "[key_name(owner)]'s antag token for [in_queue] has been denied.")
	SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
	QDEL_NULL(in_queue)
	in_queued_tier = null
	queued_donor = FALSE
	if(antag_timeout)
		deltimer(antag_timeout)
		antag_timeout = null

/datum/meta_token_holder/proc/timeout_antag_token()
	if(!in_queue)
		return
	to_chat(owner, span_boldwarning("Your request to play as [in_queue] wasn't answered within 5 minutes. Better luck next time!"))
	logger.Log(LOG_CATEGORY_META, "[key_name(owner)]'s antag token for [in_queue] has timed out.")
	SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
	QDEL_NULL(in_queue)
	in_queued_tier = null
	queued_donor = FALSE
	antag_timeout = null
