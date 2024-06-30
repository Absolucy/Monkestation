///your an evil person for grinding poor slimes up into ooze

/obj/machinery/plumbing/slime_grinder
	name = "slime grinder"
	desc = "An unholy creation, does not grind the slimes quickly."

	icon = 'monkestation/code/modules/slimecore/icons/slime_grinder.dmi'
	icon_state = "slime_grinder_backdrop"
	base_icon_state = "slime_grinder_backdrop"

	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION

	buffer = 3000
	category="Distribution"

	var/grind_time = 5 SECONDS
	///this is the face you see when you start grinding the poor slime up
	var/mob/living/basic/slime/poster_boy
	///list of all the slimes we have
	var/list/soon_to_be_crushed
	///the amount of souls we have grinded
	var/trapped_souls = 0
	///are we grinding some slimes
	var/GRINDING_SOME_SLIMES = FALSE


/obj/machinery/plumbing/slime_grinder/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)

/obj/machinery/plumbing/slime_grinder/Destroy()
	poster_boy = null
	for(var/mob/living/basic/slime/slime as anything in soon_to_be_crushed)
		if(!QDELETED(slime))
			slime.forceMove(drop_location())
	LAZYNULL(soon_to_be_crushed)
	return ..()

/obj/machinery/plumbing/slime_grinder/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(LAZYLEN(soon_to_be_crushed) && !GRINDING_SOME_SLIMES)
		Shake(6, 6, 10 SECONDS)
		GRINDING_SOME_SLIMES = TRUE
		var/datum/looping_sound/microwave/new_loop = new(src)
		new_loop.start()
		screams_of_the_damned()
		addtimer(CALLBACK(src, PROC_REF(screams_of_the_damned)), 3 SECONDS, TIMER_DELETE_ME)
		addtimer(CALLBACK(src, PROC_REF(screams_of_the_damned)), 6 SECONDS, TIMER_DELETE_ME)
		addtimer(CALLBACK(src, PROC_REF(screams_of_the_damned)), 9 SECONDS, TIMER_DELETE_ME)
		machine_do_after_visable(src, 10 SECONDS)
		GRINDING_SOME_SLIMES = FALSE
		new_loop.stop()
		playsound(src, 'sound/machines/blender.ogg', vol = 50, vary = TRUE)
		grind_slimes()

/obj/machinery/plumbing/slime_grinder/proc/screams_of_the_damned()
	for(var/mob/living/basic/slime/slime as anything in soon_to_be_crushed)
		if(prob(35))
			continue
		var/list/slime_blender = list(
			'monkestation/code/modules/slimecore/sounds/slimeblender1.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender2.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender3.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender4.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender5.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender6.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender7.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender8.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender9.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender10.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender11.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender12.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender14.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender13.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender15.ogg',
		)
		playsound(src, pick(slime_blender), vol = rand(35, 50), vary = TRUE, mixer_channel = CHANNEL_MOB_SOUNDS)
		playsound(src, 'sound/machines/blender.ogg', vol = 80, vary = TRUE, mixer_channel = CHANNEL_MACHINERY)

/obj/machinery/plumbing/slime_grinder/proc/grind_slimes()
	poster_boy = null
	update_appearance()
	for(var/mob/living/basic/slime/slime as anything in soon_to_be_crushed)
		if(QDELETED(slime))
			continue
		trapped_souls++
		reagents.add_reagent(slime.current_color.secretion_path, 25)
		LAZYREMOVE(soon_to_be_crushed, slime)
		qdel(slime)
	LAZYNULL(soon_to_be_crushed)

/obj/machinery/plumbing/slime_grinder/update_overlays()
	. = ..()
	if(!QDELETED(poster_boy))
		var/mutable_appearance/slime = poster_boy.appearance
		. += slime
	. += mutable_appearance(icon, "slime_grinder_overlay", layer + 0.1, src)

/obj/machinery/plumbing/slime_grinder/hitby(atom/movable/slime, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	if(!isslime(slime))
		return
	if(QDELETED(poster_boy))
		poster_boy = slime
		poster_boy.layer = layer
		SET_PLANE_EXPLICIT(poster_boy, plane, src)
		poster_boy.plane = plane
	SEND_SIGNAL(slime, COMSIG_EMOTION_STORE, null, EMOTION_SCARED, "I'm trapped inside a blender, I don't want to die!")
	slime.update_appearance()
	LAZYOR(soon_to_be_crushed, slime)
	slime.forceMove(src)
	update_appearance()
