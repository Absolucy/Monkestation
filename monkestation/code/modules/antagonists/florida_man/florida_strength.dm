/datum/element/florida_strength
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Time it takes to open a door with force
	var/pry_time
	/// Interaction key for if we force a door open
	var/interaction_key
	/// Typecache of assembly objects to rip apart when needed.
	var/static/list/assembly_typecache = typecacheof(list(/obj/structure/door_assembly, /obj/structure/firelock_frame))

/datum/element/florida_strength/Attach(datum/target, pry_time = 10 SECONDS, interaction_key = null)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.pry_time = pry_time
	src.interaction_key = interaction_key
	RegisterSignals(target, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK), PROC_REF(on_attack))

/datum/element/florida_strength/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK))

/// If we're targeting an airlock, open it
/datum/element/florida_strength/proc/on_attack(mob/living/attacker, atom/target, proximity_flag)
	SIGNAL_HANDLER
	if(DOING_INTERACTION_WITH_TARGET(attacker, target) || (!isnull(interaction_key) && DOING_INTERACTION(attacker, interaction_key)))
		attacker.balloon_alert(attacker, "busy!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(try_open_door(attacker, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/datum/element/florida_strength/proc/try_open_door(mob/living/attacker, obj/machinery/door/target)
	if(!istype(target) || QDELING(target) || !target.density)
		return FALSE
	var/rip_apart = target.locked || target.welded
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock_target = target
		rip_apart ||= airlock_target.seal
	if(rip_apart)
		if(target.resistance_flags & INDESTRUCTIBLE)
			target.balloon_alert(attacker, "it's sealed!")
			return TRUE
		if(!assembly_typecache)
			assembly_typecache = typecacheof(list(/obj/structure/door_assembly, /obj/structure/firelock_frame))
		attacker.visible_message(span_warning("[attacker] lets out a strained roar, completely ripping [target] apart as [attacker.p_they()] force it open!"))
		var/loc_to_check = get_turf(target)
		// rip apart the door!
		target.take_damage(INFINITY)
		// rip apart any remaining assemblies
		for(var/obj/thingy as anything in loc_to_check)
			if(is_type_in_typecache(thingy, assembly_typecache))
				thingy.take_damage(INFINITY)
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(open_door), attacker, target)
	return TRUE

/// Try opening the door, and if we can't then try forcing it
/datum/element/florida_strength/proc/open_door(mob/living/attacker, obj/machinery/door/door)
	if (!door.hasPower())
		attacker.visible_message(span_warning("[attacker] forces \the [door] to open."))
		door.open(FORCING_DOOR_CHECKS)
		return

	if (door.allowed(attacker))
		door.open(DEFAULT_DOOR_CHECKS)
		return

	attacker.visible_message(\
		message = span_warning("[attacker] starts forcing \the [door] open!"),
		blind_message = span_hear("You hear a metal screeching sound."),
	)
	playsound(door, 'sound/machines/airlock_alien_prying.ogg', vol = 100, vary = TRUE)
	door.balloon_alert(attacker, "prying...")
	if(!do_after(attacker, pry_time, door))
		door.balloon_alert(attacker, "interrupted!")
		return
	if(door.locked)
		return
	attacker.visible_message(span_warning("[attacker] forces \the [door] to open."))
	door.open(BYPASS_DOOR_CHECKS)
