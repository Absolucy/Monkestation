GLOBAL_LIST_EMPTY(machine_blessings)

/datum/religion_rites/machine_blessing
	var/list/possible_implants = list(
		/obj/item/organ/internal/cyberimp/arm/item_set/surgery,
		/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic,
		/obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/obj/item/organ/internal/cyberimp/chest/thrusters,
		/obj/item/organ/internal/eyes/robotic/glow,
	)

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/list/rite_blessings = GLOB.machine_blessings[type]
	if(!length(rite_blessings))
		GLOB.machine_blessings[type] = rite_blessings = shuffle(possible_implants)
	var/blessed_implant = rite_blessings[length(rite_blessings)]
	rite_blessings.len--
	new blessed_implant(altar_turf)
	return TRUE

/datum/religion_rites/machine_implantation
	name = "Machine Implantation"
	desc = "Apply a provided upgrade to your body. Place a cybernetic item on the altar, then buckle someone to implant them, otherwise it will implant you."
	ritual_length = 10 SECONDS
	ritual_invocations = list(
		"Lend us your power ...",
		"... We call upon you, grant us this upgrade ...",
		"... Complete us, joining man and machine ..."
	)
	invoke_msg = "... Let the mechanical parts, Merge!!"
	favor_cost = 1000
	var/obj/item/organ/internal/chosen_implant

/datum/religion_rites/machine_implantation/Destroy()
	chosen_implant = null
	return ..()

/datum/religion_rites/machine_implantation/perform_rite(mob/living/user, atom/movable/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	if(QDELETED(religious_tool))
		return FALSE
	for(var/obj/item/organ/internal/organ in get_turf(religious_tool))
		if(!istype(organ, /obj/item/organ/internal/cyberimp) && !(organ.organ_flags & ORGAN_SYNTHETIC))
			continue
		chosen_implant = organ
		break
	if(QDELETED(chosen_implant))
		to_chat(user, span_warning("A [span_bold("cybernetic")] organ or implant is required for this rite!"))
		chosen_implant = null
		return FALSE
	if(length(religious_tool.buckled_mobs))
		to_chat(user, span_warning("You're going to implant the one buckled on [religious_tool]."))
	else
		to_chat(user, span_warning("You're going to implant yourself with this ritual."))
	return ..()

/datum/religion_rites/machine_implantation/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/mob/living/carbon/rite_target
	if(!length(religious_tool.buckled_mobs))
		rite_target = user
	else
		for(var/mob/living/carbon/buckled in religious_tool.buckled_mobs)
			if(buckled.stat == DEAD)
				continue
			rite_target = buckled
			break
	if(QDELETED(rite_target))
		chosen_implant = null
		return FALSE
	chosen_implant.Insert(rite_target)
	rite_target.visible_message(span_notice("[chosen_implant] has been merged into [rite_target] by the rite of [name]!"))
	chosen_implant = null
	return TRUE
