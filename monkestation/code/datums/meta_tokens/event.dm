/datum/meta_token_holder/proc/approve_token_event()
	if(!queued_token_event)
		return
	to_chat(owner, span_boldnicegreen("Your request to trigger [queued_token_event] has been approved."))
	logger.Log(LOG_CATEGORY_META, "[key_name(owner)]'s event token for [queued_token_event] has been approved.")
	adjust_tokens(TOKEN_EVENT, -queued_token_event.token_cost)
	SStwitch.add_to_queue(initial(queued_token_event.id_tag))
	queued_token_event = null
	if(event_timeout)
		deltimer(event_timeout)
		event_timeout = null

/datum/meta_token_holder/proc/reject_token_event()
	if(!queued_token_event)
		return
	to_chat(owner, span_boldwarning("Your request to trigger [queued_token_event] has been denied."))
	logger.Log(LOG_CATEGORY_META, "[key_name(owner)]'s event token for [queued_token_event] has been denied.")
	SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
	queued_token_event = null
	if(event_timeout)
		deltimer(event_timeout)
		event_timeout = null

/datum/meta_token_holder/proc/timeout_event_token()
	if(!queued_token_event)
		return
	logger.Log(LOG_CATEGORY_META, "[key_name(owner)]'s event token for [queued_token_event] has timed out.")
	to_chat(owner, span_boldwarning("Your request to trigger [queued_token_event] wasn't answered within 5 minutes. Better luck next time!"))
	SEND_SOUND(owner, sound('sound/misc/compiler-failure.ogg', volume = 50))
	queued_token_event = null
	event_timeout = null
