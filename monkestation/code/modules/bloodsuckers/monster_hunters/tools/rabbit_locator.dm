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
	hunter = null
	return ..()

/obj/item/rabbit_locator/attack_self(mob/user, modifiers)
	if(!COOLDOWN_FINISHED(src, locator_timer))
		return
	if(QDELETED(hunter) || hunter.owner.current != user)
		to_chat(user,span_warning("It's just a normal playing card!"))
		return
	var/turf/user_turf = get_turf(user)
	if(QDELETED(user_turf) || !is_station_level(user_turf.z))
		to_chat(user, span_warning("The card cannot be used here..."))
		return
	var/obj/effect/bnuuy = get_nearest_rabbit(user)
	if(QDELETED(bnuuy))
		to_chat(user, span_warning("Can't feel any hints..."))
		return
	var/turf/bnuuy_turf = get_turf(bnuuy)
	user.balloon_alert(user, get_balloon_message(user_turf, bnuuy_turf))
	user.playsound_local(bnuuy_turf, 'monkestation/sound/bloodsuckers/rabbitlocator.ogg', vol = 75, vary = TRUE, pressure_affected = FALSE)
	COOLDOWN_START(src, locator_timer, 7 SECONDS)

/obj/item/rabbit_locator/proc/get_balloon_message(turf/user, turf/bnuuy)
	. = "error text!"
	if(user.z == bnuuy.z)
		var/dist = get_dist(user, bnuuy)
		var/dir = get_dir(user, bnuuy)
		switch(dist)
			if(0 to 15)
				return "very near, [dir2text(dir)]!"
			if(16 to 31)
				return "near, [dir2text(dir)]!"
			if(32 to 127)
				return "far, [dir2text(dir)]!"
			else
				return "very far!"
	else
		var/z_difference = abs(bnuuy.z - user.z)
		return "[z_difference] [z_difference == 1 ? "floor" : "floors"] [bnuuy.z > user.z ? "above" : "below"]"

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
	return selected_bunny
