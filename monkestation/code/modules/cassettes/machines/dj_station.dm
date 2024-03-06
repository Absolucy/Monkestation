GLOBAL_VAR(dj_broadcast)
GLOBAL_DATUM(dj_booth, /obj/machinery/cassette/dj_station)

/obj/item/clothing/ears
	//can we be used to listen to radio?
	var/radio_compat = FALSE

/obj/machinery/cassette/dj_station
	name = "Cassette Player"
	desc = "Plays Space Music Board approved cassettes for anyone in the station to listen to!"

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "cassette_player"

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	density = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING
	var/broadcasting = FALSE
	var/obj/item/device/cassette_tape/inserted_tape
	var/list/people_with_signals = list()
	var/list/active_listeners = list()

	//tape stuff goes here
	var/pl_index = 0
	var/list/current_playlist = list()
	var/list/current_namelist = list()

	/// The yt-dlp data of the current song being played.
	var/datum/yt_dlp_info/current_song
	/// The world time where the current song started playing.
	var/song_start_time

	var/last_hud_fraction
	var/mutable_appearance/hover_appearance
	var/datum/atom_hud/alternate_appearance/basic/music_cooldown/hover_popup

	/// How long before another song can be played, after the previous song ends.
	var/cooldown = 4 MINUTES
	/// Whether the cassette player is ready for another interaction at the moment.
	var/doing_a_thing = FALSE
	// The cooldown timer for when a song can be played again.
	COOLDOWN_DECLARE(song_cooldown)

/obj/machinery/cassette/dj_station/Initialize(mapload)
	. = ..()
	if(QDELETED(GLOB.dj_booth))
		GLOB.dj_booth = src
	register_context()

/obj/machinery/cassette/dj_station/Destroy()
	if(GLOB.dj_booth == src)
		GLOB.dj_booth = null
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(hover_popup)
	return ..()

/obj/machinery/cassette/dj_station/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(inserted_tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"
		if(!broadcasting)
			context[SCREENTIP_CONTEXT_LMB] = "Play Tape"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/cassette/dj_station/examine(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, song_cooldown))
		. += span_notice("It seems to be cooling down, you estimate it will take about [DisplayTimeText(COOLDOWN_TIMELEFT(src, song_cooldown))].")

/obj/machinery/cassette/dj_station/process(seconds_per_tick)
	manage_hud_as_needed()
/obj/machinery/cassette/dj_station/attack_hand(mob/user)
	. = ..()
	if(QDELETED(inserted_tape))
		return
	if((!COOLDOWN_FINISHED(src, song_cooldown)) && !broadcasting)
		//to_chat(user, span_notice("The [src] feels hot to the touch and needs time to cooldown."))
		//to_chat(user, span_info("You estimate it will take about [time_left ? DisplayTimeText(((time_left * 10) + 6000)) : DisplayTimeText(COOLDOWN_TIMELEFT(src, song_cooldown))] to cool down."))
		return
	message_admins("[src] started broadcasting [inserted_tape] interacted with by [user]")
	logger.Log(LOG_CATEGORY_MUSIC, "[src] started broadcasting [inserted_tape]")
	start_broadcast()

/obj/machinery/cassette/dj_station/AltClick(mob/user)
	. = ..()
	if(!isliving(user) || !user.Adjacent(src))
		return
	if(!inserted_tape)
		return
	if(broadcasting)
		next_song()

/obj/machinery/cassette/dj_station/CtrlClick(mob/user)
	. = ..()
	if(!inserted_tape || broadcasting)
		return
	if(Adjacent(user) && !issiliconoradminghost(user))
		if(!user.put_in_hands(inserted_tape))
			inserted_tape.forceMove(drop_location())
	else
		inserted_tape.forceMove(drop_location())
	inserted_tape = null
	time_left = 0
	current_song_duration = 0
	pl_index = 0
	current_playlist = list()
	current_namelist = list()
	stop_broadcast(TRUE)

/obj/machinery/cassette/dj_station/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/device/cassette_tape))
		return
	var/obj/item/device/cassette_tape/attacked = weapon
	if(!attacked.approved_tape)
		to_chat(user, span_warning("The [src] smartly rejects the bootleg cassette tape"))
		return
	if(!inserted_tape)
		insert_tape(attacked)
	else
		if(!broadcasting)
			if(Adjacent(user) && !issiliconoradminghost(user))
				if(!user.put_in_hands(inserted_tape))
					inserted_tape.forceMove(drop_location())
			else
				inserted_tape.forceMove(drop_location())
			inserted_tape = null
			time_left = 0
			current_song_duration = 0
			pl_index = 0
			current_playlist = list()
			current_namelist = list()
			insert_tape(attacked)
			if(broadcasting)
				stop_broadcast(TRUE)

/obj/machinery/cassette/dj_station/MouseEntered(location, control, params)
	. = ..()
	if(!QDELETED(usr) && !COOLDOWN_FINISHED(src, song_cooldown))
		manage_hud_as_needed()
		hover_popup?.show_to(usr)

/obj/machinery/cassette/dj_station/MouseExited(location, control, params)
	. = ..()
	if(!QDELETED(usr) && !QDELETED(hover_popup) && !COOLDOWN_FINISHED(src, song_cooldown))
		hover_popup.hide_from(usr)
		manage_hud_as_needed(cleanup = TRUE)

/obj/machinery/cassette/dj_station/proc/get_current_progress_fraction()
	if(COOLDOWN_FINISHED(src, song_cooldown))
		return null
	return get_visual_timer_fraction(world.time - (song_cooldown - cooldown), cooldown)

/obj/machinery/cassette/dj_station/proc/manage_hud_as_needed(cleanup = FALSE)
	if(COOLDOWN_FINISHED(src, song_cooldown) || (cleanup && !QDELETED(hover_popup) && !length(hover_popup.hud_users_all_z_levels)))
		// don't bother keeping the hud around if it isn't needed
		QDEL_NULL(hover_popup)
		last_hud_fraction = null
		return
	if(!isnull(last_hud_fraction) && !QDELETED(hover_popup) && last_hud_fraction == get_current_progress_fraction())
		// nothing's changed, don't waste time updating the circle thingymajig, just update the text
		refresh_cooldown_maptext()
		return
	setup_hud()

/obj/machinery/cassette/dj_station/proc/setup_hud()
	// delete old hud if it exists and collect a list of its users
	var/list/mob/old_users
	if(!QDELETED(hover_popup))
		old_users = hover_popup.hud_users_all_z_levels.Copy()
		QDEL_NULL(hover_popup)

	// setup new hover appearance
	var/fraction = get_current_progress_fraction()
	hover_appearance = image(visual_timer(fraction))
	hover_appearance.pixel_y = 32
	hover_appearance.loc = src
	SET_PLANE_EXPLICIT(hover_appearance, HUD_PLANE, src)
	hover_appearance.plane = HUD_PLANE
	hover_appearance.appearance_flags = RESET_COLOR

	// now setup the actual hud
	hover_popup = add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/music_cooldown, "music_cooldown", hover_appearance)
	// and the cooldown maptext
	refresh_cooldown_maptext()

	for(var/mob/old_user as anything in old_users)
		if(QDELETED(old_user))
			continue
		hover_popup.show_to(old_user)

/obj/machinery/cassette/dj_station/proc/refresh_cooldown_maptext()
	if(!hover_popup)
		return
	if(!hover_popup.cooldown_maptext)
		hover_popup.cooldown_maptext = image(loc = src, layer = CHAT_LAYER)
		SET_PLANE_EXPLICIT(hover_popup.cooldown_maptext, HUD_PLANE, src)
		hover_popup.cooldown_maptext.plane = HUD_PLANE
		hover_popup.cooldown_maptext.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
		hover_popup.cooldown_maptext.maptext_width = world.icon_size
		hover_popup.cooldown_maptext.maptext_height = world.icon_size / 2
		hover_popup.cooldown_maptext.maptext_y = world.icon_size / 2
	var/maptext
	if(COOLDOWN_FINISHED(src, song_cooldown))
		maptext = "ready!"
	else
		var/cooldown_in_seconds = round(COOLDOWN_TIMELEFT(src, song_cooldown) * 0.1)
		var/minutes = FLOOR(cooldown_in_seconds / 60, 1)
		if(minutes > 0)
			var/seconds = round(cooldown_in_seconds % 60)
			maptext = "[minutes]m [seconds]s"
		else
			maptext = "[cooldown_in_seconds]s"
	hover_popup.cooldown_maptext.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: center'>[maptext]</span>")
	hover_popup.give_cooldowns()

/obj/machinery/cassette/dj_station/proc/insert_tape(obj/item/device/cassette_tape/CTape)
	if(inserted_tape || !istype(CTape))
		return

	inserted_tape = CTape
	CTape.forceMove(src)

	update_appearance()
	pl_index = 1
	if(inserted_tape.songs["side1"] && inserted_tape.songs["side2"])
		var/list/list = inserted_tape.songs["[inserted_tape.flipped ? "side2" : "side1"]"]
		for(var/song in list)
			current_playlist += song

		var/list/name_list = inserted_tape.song_names["[inserted_tape.flipped ? "side2" : "side1"]"]
		for(var/song in name_list)
			current_namelist += song

/obj/machinery/cassette/dj_station/proc/stop_broadcast(soft = FALSE)
	STOP_PROCESSING(SSprocessing, src)
	GLOB.dj_broadcast = FALSE
	broadcasting = FALSE
	message_admins("[src] has stopped broadcasting [inserted_tape].")
	logger.Log(LOG_CATEGORY_MUSIC, "[src] has stopped broadcasting [inserted_tape]")
	for(var/client/anything as anything in active_listeners)
		if(!istype(anything))
			continue
		anything.tgui_panel?.stop_music()
		GLOB.youtube_exempt["dj-station"] -= anything
	active_listeners = list()

	if(!soft)
		for(var/mob/living/carbon/anything as anything in people_with_signals)
			if(!istype(anything))
				continue
			UnregisterSignal(anything, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_CARBON_UNEQUIP_EARS, COMSIG_CARBON_EQUIP_EARS))
		people_with_signals = list()

/obj/machinery/cassette/dj_station/proc/start_broadcast()
	var/choice = tgui_input_list(usr, "Choose which song to play.", "[src]", current_namelist)
	if(!choice)
		return
	var/list_index = current_namelist.Find(choice)
	if(!list_index)
		return
	GLOB.dj_broadcast = TRUE
	pl_index = list_index

	var/list/viable_z = SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING, ZTRAIT_CENTCOM, ZTRAIT_RESERVED))
	for(var/mob/person as anything in GLOB.player_list)
		if(isAI(person) || isobserver(person) || isaicamera(person) || iscyborg(person))
			active_listeners |=	person.client
		if(iscarbon(person))
			var/mob/living/carbon/anything = person
			if(!(anything in people_with_signals))
				if(!istype(anything))
					continue

				RegisterSignal(anything, COMSIG_CARBON_UNEQUIP_EARS, PROC_REF(stop_solo_broadcast))
				RegisterSignals(anything, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_CARBON_EQUIP_EARS), PROC_REF(check_solo_broadcast))
				people_with_signals |= anything

			if(!(anything.client in active_listeners))
				if(!(anything.z in viable_z))
					continue

				if(!anything.client)
					continue

				if(anything.client in GLOB.youtube_exempt["walkman"])
					continue

				var/obj/item/ear_slot = anything.get_item_by_slot(ITEM_SLOT_EARS)
				if(istype(ear_slot, /obj/item/clothing/ears))
					var/obj/item/clothing/ears/worn
					if(!worn || !worn?.radio_compat)
						continue
				else if(!istype(ear_slot, /obj/item/radio/headset))
					continue

				if(!anything.client.prefs?.read_preference(/datum/preference/toggle/hear_music))
					continue

				active_listeners |=	anything.client

	if(!length(active_listeners))
		return

	start_playing(active_listeners)
	START_PROCESSING(SSprocessing, src)


/obj/machinery/cassette/dj_station/proc/check_solo_broadcast(mob/living/carbon/source, obj/item/clothing/ears/ear_item)
	SIGNAL_HANDLER

	if(!istype(source))
		return

	if(istype(ear_item, /obj/item/clothing/ears))
		var/obj/item/clothing/ears/worn
		if(!worn || !worn?.radio_compat)
			return
	else if(!istype(ear_item, /obj/item/radio/headset))
		return

	var/list/viable_z = SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING, ZTRAIT_CENTCOM))
	if(!(source.z in viable_z) || !source.client)
		return

	if(!source.client.prefs?.read_preference(/datum/preference/toggle/hear_music))
		return

	active_listeners |= source.client
	GLOB.youtube_exempt["dj-station"] |= source.client
	INVOKE_ASYNC(src, PROC_REF(start_playing),list(source.client))

/obj/machinery/cassette/dj_station/proc/stop_solo_broadcast(mob/living/carbon/source)
	SIGNAL_HANDLER

	if(!source.client || !(source.client in active_listeners))
		return

	active_listeners -= source.client
	GLOB.youtube_exempt["dj-station"] -= source.client
	source.client.tgui_panel?.stop_music()

/*
/obj/machinery/cassette/dj_station/proc/start_playing(list/clients)
	if(!inserted_tape)
		if(broadcasting)
			stop_broadcast(TRUE)
		return

	waiting_for_yield = TRUE
	if(findtext(current_playlist[pl_index], GLOB.is_http_protocol))
		///invoking youtube-dl
		var/ytdl = CONFIG_GET(string/invoke_youtubedl)
		///the input for ytdl handled by the song list
		var/web_sound_input
		///the url for youtube-dl
		var/web_sound_url = ""
		///all extra data from the youtube-dl really want the name
		var/list/music_extra_data = list()
		web_sound_input = trim(current_playlist[pl_index])
		if(!(web_sound_input in GLOB.parsed_audio))
			///scrubbing the input before putting it in the shell
			var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
			///putting it in the shell
			var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
			///any errors
			var/errorlevel = output[SHELLEO_ERRORLEVEL]
			///the standard output
			var/stdout = output[SHELLEO_STDOUT]
			if(!errorlevel)
				///list for all the output data to go to
				var/list/data
				try
					data = json_decode(stdout)
				catch(var/exception/error) ///catch errors here
					to_chat(src, "<span class='boldwarning'>Youtube-dl JSON parsing FAILED:</span>", confidential = TRUE)
					to_chat(src, "<span class='warning'>[error]: [stdout]</span>", confidential = TRUE)
					return

				if (data["url"])
					web_sound_url = data["url"]
					music_extra_data["start"] = data["start_time"]
					music_extra_data["end"] = data["end_time"]
					music_extra_data["link"] = data["webpage_url"]
					music_extra_data["title"] = data["title"]
					if(music_extra_data["start"])
						time_left = data["duration"] - music_extra_data["start"]
					else
						time_left = data["duration"]

					current_song_duration = data["duration"]

				GLOB.parsed_audio["[web_sound_input]"] = data
		else
			var/list/data = GLOB.parsed_audio["[web_sound_input]"]
			web_sound_url = data["url"]
			music_extra_data["start"] = data["start_time"]
			music_extra_data["end"] = data["end_time"]
			music_extra_data["link"] = data["webpage_url"]
			music_extra_data["title"] = data["title"]
			if(time_left <= 0)
				if(music_extra_data["start"])
					time_left = data["duration"] - music_extra_data["start"]
				else
					time_left = data["duration"]

			current_song_duration = data["duration"]
			music_extra_data["duration"] = data["duration"]

			if(time_left > 0)
				music_extra_data["start"] = music_extra_data["duration"] - time_left

		for(var/client/anything as anything in clients)
			if(!istype(anything))
				continue
			anything.tgui_panel?.play_music(web_sound_url, music_extra_data)
			GLOB.youtube_exempt["dj-station"] |= anything
		broadcasting = TRUE
	waiting_for_yield = FALSE
*/

/obj/machinery/cassette/dj_station/proc/ready()
	return !doing_a_thing && COOLDOWN_FINISHED(src, song_cooldown)

/obj/machinery/cassette/dj_station/proc/play_to_clients(list/clients)
	if(isnull(current_song))
		return FALSE
	if(!islist(clients))
		clients = list(clients)
	for(var/client/client as anything in clients)
		if(!istype(client))
			continue
		current_song.play(client)


/obj/machinery/cassette/dj_station/proc/add_new_player(mob/living/carbon/new_player)
	if(!(new_player in people_with_signals))
		RegisterSignal(new_player, COMSIG_CARBON_UNEQUIP_EARS, PROC_REF(stop_solo_broadcast))
		RegisterSignals(new_player, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_CARBON_EQUIP_EARS), PROC_REF(check_solo_broadcast))
		people_with_signals |= new_player

	if(!broadcasting)
		return

	var/obj/item/ear_slot = new_player.get_item_by_slot(ITEM_SLOT_EARS)
	if(istype(ear_slot, /obj/item/clothing/ears))
		var/obj/item/clothing/ears/worn
		if(!worn || !worn?.radio_compat)
			return
	else if(!istype(ear_slot, /obj/item/radio/headset))
		return
	var/list/viable_z = SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING, ZTRAIT_CENTCOM))
	if(!(new_player.z in viable_z))
		return

	if(!(new_player.client in active_listeners))
		active_listeners |= new_player.client
		start_playing(list(new_player.client))

/obj/machinery/cassette/dj_station/proc/next_song()
	waiting_for_yield = TRUE
	var/choice = tgui_input_number(usr, "Choose which song number to play.", "[src]", 1, length(current_playlist), 1)
	if(!choice)
		waiting_for_yield = FALSE
		stop_broadcast()
		return
	GLOB.dj_broadcast = TRUE
	pl_index = choice

	pl_index++
	start_playing(active_listeners)
