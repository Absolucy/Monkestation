#define PLAY_SOUND(the) playsound(src, ##the, 90, FALSE)

GLOBAL_VAR(dj_broadcast)
GLOBAL_DATUM(dj_booth, /obj/machinery/dj_station)

/obj/item/clothing/ears
	//can we be used to listen to radio?
	var/radio_compat = FALSE

/obj/machinery/dj_station
	name = "Cassette Player"
	desc = "Plays Space Music Board approved cassettes for anyone in the station to listen to."

	icon = 'icons/obj/cassettes/radio_station.dmi'
	icon_state = "cassette_player"

	use_power = NO_POWER_USE
	processing_flags = NONE

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	interaction_flags_machine = INTERACT_MACHINE_SET_MACHINE

	anchored = TRUE
	density = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING

	var/broadcasting = FALSE
	/// The currently inserted cassette, if any.
	var/obj/item/cassette_tape/inserted_tape
	/// The song currently being played, if any.
	var/datum/cassette_song/playing
	/// The REALTIMEOFDAY that the current song was started.
	var/song_start_time

	COOLDOWN_DECLARE(next_song_timer)
	// Are we switching tracks right now? (AKA, we cant do anything else with the thing until it switches tracks.)
	COOLDOWN_DECLARE(switching_tracks)

/obj/machinery/dj_station/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	register_context()
	if(QDELETED(GLOB.dj_booth))
		GLOB.dj_booth = src
	ADD_TRAIT(src, TRAIT_ALT_CLICK_BLOCKER, INNATE_TRAIT)

/obj/machinery/dj_station/Destroy()
	if(!QDELETED(inserted_tape))
		inserted_tape.forceMove(drop_location())
	inserted_tape = null
	playing = null
	if(GLOB.dj_booth == src)
		GLOB.dj_booth = null
	return ..()

/obj/machinery/dj_station/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(istype(held_item, /obj/item/cassette_tape))
		context[SCREENTIP_CONTEXT_LMB] = inserted_tape ? "Swap Tape" : "Insert Tape"
	else if(!held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Open UI"

	if(inserted_tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"

/obj/machinery/dj_station/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/cassette_tape))
		return ..()
	var/obj/item/cassette_tape/old_tape = inserted_tape
	// TODO, if there is a tape, play a different noise of us taking out the cassette.
	if(old_tape)
		old_tape.forceMove(drop_location())
		inserted_tape = null
		PLAY_SOUND(SFX_DJSTATION_OPENTAKEOUT)
		if (!do_after(user, 1.2 SECONDS))
			return

	if (old_tape)
		PLAY_SOUND(SFX_DJSTATION_PUTINANDCLOSE)
		if (!do_after(user, 1.3 SECONDS))
			return
	else
		PLAY_SOUND(SFX_DJSTATION_OPENPUTINANDCLOSE)
		if (!do_after(user, 2.2 SECONDS))
			return
	if(user.transferItemToLoc(weapon, src))
		balloon_alert(user, "inserted tape")
		inserted_tape = weapon
		if(old_tape)
			user.put_in_hands(old_tape)
	update_static_data_for_all_viewers()

/obj/machinery/dj_station/proc/eject_tape(mob/user)
	if(inserted_tape)
		PLAY_SOUND(SFX_DJSTATION_OPENTAKEOUTANDCLOSE)
		if (!do_after(user, 1.5 SECONDS))
			return
		inserted_tape.forceMove(drop_location())
		if(user)
			balloon_alert(user, "tape ejected")
			user.put_in_hands(inserted_tape)
			inserted_tape = null
			update_static_data_for_all_viewers()
	else if(user)
		balloon_alert(user, "no tape inserted!")

/obj/machinery/dj_station/CtrlClick(mob/user)
	if(can_interact(user))
		if(!COOLDOWN_FINISHED(src, switching_tracks))
			balloon_alert(user, "busy switching tracks!")
			return
		eject_tape(user)
	return ..()

/obj/machinery/dj_station/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DjStation")
		ui.open()

/obj/machinery/dj_station/ui_data(mob/user)
	var/is_switching_tracks = !COOLDOWN_FINISHED(src, switching_tracks)
	. = list(
		"broadcasting" = broadcasting,
		"song_cooldown" = COOLDOWN_TIMELEFT(src, next_song_timer),
		"progress" = song_start_time ? (REALTIMEOFDAY - song_start_time) : 0,
		"current_song" = is_switching_tracks ? null :
			inserted_tape && inserted_tape.cassette_data ? inserted_tape.cassette_data.get_side(!inserted_tape.flipped).songs.Find(playing) - 1 : null,
		"switching_tracks" = !COOLDOWN_FINISHED(src, switching_tracks)
	)


/obj/machinery/dj_station/ui_static_data(mob/user)
	. = list("side" = !!inserted_tape?.flipped)
	var/datum/cassette/cassette = inserted_tape?.cassette_data
	if(cassette)
		var/datum/cassette_side/side = cassette.get_side()
		.["cassette"] = list(
			"name" = cassette.name,
			"desc" = cassette.desc,
			"author" = cassette.author?.name,
			"design" = side?.design || /datum/cassette_side::design,
			"songs" = list(),
		)
		for(var/datum/cassette_song/song as anything in side?.songs)
			.["cassette"]["songs"] += list(list(
				"name" = song.name,
				"url" = song.url,
				"length" = song.length,
			))
	else
		.["cassette"] = null

/obj/machinery/dj_station/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .

	var/mob/user = ui.user
	testing("dj station [action]([json_encode(params)])")
	switch(action)
		if("eject", "play", "stop")
			if(!COOLDOWN_FINISHED(src, switching_tracks))
				balloon_alert(user, "busy switching tracks!")
				return

	switch(action)
		if("eject")
			eject_tape(user)
			return TRUE
		if("play")
			PLAY_SOUND(SFX_DJSTATION_PLAY)
			// TODO: play current song
			return TRUE
		if("stop")
			PLAY_SOUND(SFX_DJSTATION_STOP)
			// TODO: stop current song
			return TRUE
		if("set_track")
			. = TRUE
			var/index = params["index"]
			if(!isnum(index))
				CRASH("tried to pass non-number index ([index]) to set_track??? this is prolly a bug.")
			index++
			if (!inserted_tape)
				balloon_alert("no cassette tape inserted!")
				return
			if (!inserted_tape.cassette_data)
				balloon_alert("this cassette is blank!")
				return
			var/list/cassette_songs = inserted_tape.cassette_data.get_side(!inserted_tape.flipped).songs

			var/song_count = length(cassette_songs)
			if (!song_count)
				balloon_alert("no tracks on this side!")
				return
			if (!inserted_tape)
				balloon_alert("no tape inserted!")
				return
			var/datum/cassette_song/found_track = cassette_songs[index]
			if (!found_track)
				balloon_alert("that track doesnt exist!")
				return

			if (playing)
				PLAY_SOUND(SFX_DJSTATION_STOP)
				sleep(0.2 SECONDS)
			PLAY_SOUND(SFX_DJSTATION_TRACKSWITCH)
			COOLDOWN_START(src, switching_tracks, 2.1 SECONDS)
			sleep(2.1 SECONDS)
			playing = found_track


// It cannot be stopped.
/obj/machinery/dj_station/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	return

/obj/machinery/dj_station/emp_act(severity)
	return

// Funny.
/obj/machinery/dj_station/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	SHOULD_CALL_PARENT(FALSE)
	visible_message(span_warning("[hitting_projectile] bounces harmlessly off of [src]!"))
	// doesn't actually do any damage, this is meant to annoy people when they try to shoot it bc someone played pickle rick
	hitting_projectile.damage = 0
	hitting_projectile.stamina = 0
	hitting_projectile.debilitating = FALSE
	hitting_projectile.reflect(src)
	return BULLET_ACT_FORCE_PIERCE

#undef PLAY_SOUND
