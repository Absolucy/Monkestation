/obj/item/rabbit_locator
	name = "Accursed Red Queen card"
	desc = "Hunts down the white rabbits.\n<b>This does <i>NOT</i> track down monster targets, it tracks down the rabbits you must collect.</b>"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	icon_state = "locator"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///the hunter the card is tied too
	var/datum/antagonist/monsterhunter/hunter
	COOLDOWN_DECLARE(locator_timer)

/obj/item/rabbit_locator/Initialize(mapload, datum/antagonist/monsterhunter/owner)
	. = ..()
	if(!QDELETED(owner))
		hunter = owner
		hunter.locator = src

/obj/item/rabbit_locator/Destroy()
	if(hunter?.locator == src)
		hunter.locator = null
	return ..()

/obj/item/rabbit_locator/attack_self(mob/user, modifiers)
	if(!COOLDOWN_FINISHED(src, locator_timer))
		return
	if(QDELETED(hunter) || hunter.owner.current != user)
		to_chat(user, span_warning("It's just a normal playing card!"))
		return
	var/turf/user_turf = get_turf(user)
	if(QDELETED(user_turf) || !is_station_level(user_turf.z))
		to_chat(user, span_warning("The card cannot be used here..."))
		return
	var/obj/effect/bnuuy = get_nearest_rabbit(user)
	if(QDELETED(bnuuy))
		user.balloon_alert(user, "no rabbits")
		to_chat(user, span_warning("Can't feel any hints..."))
		return
	var/turf/bnuuy_turf = get_turf(bnuuy)
	var/sound_value
	var/direction = get_dir(user_turf, bnuuy_turf)
	user.balloon_alert(user, "rabbit [dir2text(direction)]!")
	switch(get_dist(user_turf, bnuuy_turf))
		if(0 to 9)
			sound_value = 100
			to_chat(user, span_warning("Here... the white rabbit is definitely here, in \the [span_hypnophrase("[get_area(bnuuy_turf)]")]!"))
		if(10 to 19)
			sound_value = 80
			to_chat(user, span_warning("You feel a VERY strong hint..."))
		if(20 to 29)
			sound_value = 60
			to_chat(user, span_warning("You feel a strong hint..."))
		if(30 to 39)
			sound_value = 40
			to_chat(user, span_warning("You feel a mild hint..."))
		if(40 to 49)
			sound_value = 20
			to_chat(user, span_warning("You feel the slightest hint..."))
		else
			sound_value = 0
			to_chat(user, span_warning("Too far away..."))
	user.playsound_local(bnuuy_turf, 'monkestation/sound/bloodsuckers/rabbitlocator.ogg', vol = sound_value, pressure_affected = FALSE)
	COOLDOWN_START(src, locator_timer, 7 SECONDS)

/obj/item/rabbit_locator/proc/get_nearest_rabbit(mob/user)
	var/dist = 1000
	if(!length(hunter?.rabbits))
		return
	var/obj/effect/selected_bunny
	for(var/obj/effect/located as anything in hunter.rabbits)
		if(get_dist(user, located) < dist)
			dist = get_dist(user, located)
			selected_bunny = located
	if(QDELETED(selected_bunny))
		return
	var/z_difference = abs(selected_bunny.z - user.z)
	if(dist < 50 && z_difference != 0)
		var/floor_msg = "[z_difference] [z_difference == 1 ? "floor" : "floors"] [selected_bunny.z > user.z ? "above" : "below"]"
		user.balloon_alert(user, "[floor_msg]!")
		to_chat(user, span_warning("[floor_msg]..."))
	return selected_bunny
