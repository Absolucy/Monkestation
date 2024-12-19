/// Simple thing that marks an items as having come from a gift.
/datum/component/gift_item
	/// The ckey of the player who opened the gift.
	var/ckey
	/// Weakref to the mob who opened the gift.
	var/datum/weakref/giftee
	/// Weakref to the mob who opened the gift.
	var/datum/weakref/mind
	/// The (real) name of mob who opened the gift.
	var/name
	/// The `world.time` when the gift was opened.
	var/open_world_time
	/// The `world.timeofday` when the gift was opened.
	var/open_timeofday

/datum/component/gift_item/Initialize(mob/living/giftee)
	if(!isitem(parent))
		stack_trace("Tried to assign [type] to a non-item")
		return COMPONENT_INCOMPATIBLE
	if(!isliving(giftee))
		stack_trace("Tried to assign [type] to something that wasn't a living mob!")
		return COMPONENT_INCOMPATIBLE
	if(!giftee.ckey)
		stack_trace("Tried to assign [type] to a non-player mob!")
		return COMPONENT_INCOMPATIBLE
	src.ckey = giftee.ckey
	src.giftee = WEAKREF(giftee)
	src.mind = WEAKREF(giftee.mind)
	src.name = "[giftee.mind?.name || giftee.real_name || giftee.name || "N/A"]"
	src.open_world_time = world.time
	src.open_timeofday = world.timeofday

/datum/component/gift_item/Destroy(force)
	giftee = null
	mind = null
	return ..()

/datum/component/gift_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	ADD_TRAIT(parent, TRAIT_GIFT_ITEM, type)

/datum/component/gift_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	REMOVE_TRAIT(parent, TRAIT_GIFT_ITEM, type)

/datum/component/gift_item/proc/on_examine(obj/item/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	var/mob/living/opener = giftee.resolve()
	var/datum/mind/opener_mind = mind.resolve()
	if(check_rights_for(examiner.client, R_ADMIN))
		// ensure we always target the right mob for the admin buttons
		var/mob/living/target_mob
		if(opener?.ckey == ckey)
			target_mob = opener
		else if(opener_mind?.current?.ckey == ckey)
			target_mob = opener_mind.current
		else if(GLOB.directory[ckey])
			var/client/current_client = GLOB.directory[ckey]
			target_mob = current_client.mob
		else
			for(var/mob/mob in GLOB.mob_list)
				if(mob.ckey == ckey)
					target_mob = mob
					break
		examine_text += span_bold("\[") + span_info(" This item came from a gift opened by [span_name(name)] ([ckey]) [ADMIN_FULLMONTY_NONAME(target_mob)] ") + span_bold("\]")
		examine_text += span_bold("\[") + span_info(" It was unwrapped from a gift [span_bold(DisplayTimeText(world.time - open_world_time) + " ago")], at server time [span_bold(time2text(open_timeofday, "YYYY-MM-DD hh:mm:ss"))] ") + span_bold("\]")
	else if(isobserver(examiner) || HAS_TRAIT(examiner, TRAIT_PRESENT_VISION) || SSticker.current_state >= GAME_STATE_FINISHED)
		examine_text += span_bold("\[") + span_info(" This item came from a gift opened by [span_name(name)] [DisplayTimeText(world.time - open_world_time)] ago ") + span_bold("\]")
	else
		examine_text += span_bold("\[") + span_info(" This item seems to have been a gift! ") + span_bold("\]")

