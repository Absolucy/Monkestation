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
	/// The world time when the gift was opened.
	var/open_time

/datum/component/gift_item/Initialize(mob/giftee)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.ckey = giftee.ckey
	src.giftee = WEAKREF(giftee)
	src.mind = WEAKREF(giftee.mind)
	src.name = "[giftee.mind?.name || giftee.real_name || giftee.name || "N/A"]"
	src.open_time = world.time

/datum/component/gift_item/Destroy(force)
	giftee = null
	mind = null
	return ..()

/datum/component/gift_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/gift_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

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

