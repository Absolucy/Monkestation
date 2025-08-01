///Global list containing any and all soulcatchers
GLOBAL_LIST_EMPTY(soulcatchers)

#define SOULCATCHER_DEFAULT_COLOR "#75D5E1"
#define SOULCATCHER_WARNING_MESSAGE "You have entered a soulcatcher, do not share any information you have received while a ghost. If you have died within the round, you do not know your identity until your body has been scanned, standard blackout policy also applies."

/**
 * Soulcatcher Component
 *
 * This component functions as a bridge between the `soulcatcher_room` attached to itself and the parented datum.
 * It handles the creation of new soulcatcher rooms, TGUI, and relaying messages to the parent datum.
 * If the component is deleted, any soulcatcher rooms inside of `soulcatcher_rooms` will be deleted.
 */
/datum/component/soulcatcher
	/// What is the name of the soulcatcher?
	var/name = "soulcatcher"
	/// What rooms are linked to this soulcatcher
	var/list/soulcatcher_rooms = list()
	/// What soulcatcher room are verbs sending messages to?
	var/datum/soulcatcher_room/targeted_soulcatcher_room
	/// What theme are we using for our soulcatcher UI?
	var/ui_theme = "default"

	/// Are ghosts currently able to join this soulcatcher?
	var/ghost_joinable = TRUE
	/// Do we want to ask the user permission before the ghost joins?
	var/require_approval = TRUE
	/// What is the max number of people we can keep in this soulcatcher? If this is set to `FALSE` we don't have a limit
	var/max_souls = FALSE
	/// Are are the souls inside able to emote/speak as the parent?
	var/communicate_as_parent = TRUE
	/// Is the soulcatcher removable from the parent object?
	var/removable = FALSE

/datum/component/soulcatcher/New()
	. = ..()
	if(!parent)
		return COMPONENT_INCOMPATIBLE

	create_room()
	targeted_soulcatcher_room = soulcatcher_rooms[1]
	GLOB.soulcatchers += src

	var/obj/item/soulcatcher_holder/soul_holder = parent
	if(istype(soul_holder) && ismob(soul_holder.loc))
		var/mob/living/soulcatcher_owner = soul_holder.loc
		add_verb(soulcatcher_owner, list(
			/mob/living/proc/soulcatcher_say,
			/mob/living/proc/soulcatcher_emote,
		))

/datum/component/soulcatcher/Destroy(force)
	GLOB.soulcatchers -= src

	targeted_soulcatcher_room = null
	for(var/datum/soulcatcher_room as anything in soulcatcher_rooms)
		soulcatcher_rooms -= soulcatcher_room
		qdel(soulcatcher_room)

	var/mob/living/soulcatcher_owner = parent
	var/obj/item/organ/internal/cyberimp/brain/nif/parent_nif = parent
	if(istype(parent_nif))
		soulcatcher_owner = parent_nif.linked_mob

	if(istype(soulcatcher_owner))
		remove_verb(soulcatcher_owner, list(
			/mob/living/proc/soulcatcher_say,
			/mob/living/proc/soulcatcher_emote,
		))

	return ..()

/**
 * Creates a `/datum/soulcatcher_room` and adds it to the `soulcatcher_rooms` list.
 *
 * Arguments
 * * target_name - The name that we want to assign to the created room.
 * * target_desc - The description that we want to assign to the created room.
 */
/datum/component/soulcatcher/proc/create_room(target_name = "Default Room", \
										target_desc = "An orange platform suspended in space orbited by reflective cubes of various sizes. There really isn't much here at the moment.")
	var/datum/soulcatcher_room/created_room = new(src)
	created_room.name = target_name
	created_room.room_description = target_desc
	soulcatcher_rooms += created_room

	created_room.master_soulcatcher = WEAKREF(src)

/// Tries to find out who is currently using the soulcatcher, returns the holder. If no holder can be found, returns FALSE
/datum/component/soulcatcher/proc/get_current_holder()
	var/mob/living/holder

	if(!istype(parent, /obj/item))
		return FALSE

	var/obj/item/parent_item = parent
	holder = parent_item.loc

	if(!istype(holder))
		return FALSE

	return holder

/// Receives a message from a soulcatcher room.
/datum/component/soulcatcher/proc/receive_message(message_to_receive)
	if(!message_to_receive)
		return FALSE

	var/mob/living/soulcatcher_owner = get_current_holder()
	if(!soulcatcher_owner)
		return FALSE

	to_chat(soulcatcher_owner, message_to_receive)
	return TRUE

/// Attempts to ping the current user of the soulcatcher, asking them if `joiner_name` is allowed in. If they are, the proc returns `TRUE`, otherwise returns FALSE
/datum/component/soulcatcher/proc/get_approval(joiner_name)
	if(!require_approval)
		return TRUE

	var/mob/living/soulcatcher_owner = get_current_holder()

	if(!soulcatcher_owner)
		return FALSE

	if(tgui_alert(soulcatcher_owner, "Do you wish to allow [joiner_name] into your soulcatcher?", name, list("Yes", "No"), autofocus = FALSE) != "Yes")
		return FALSE

	return TRUE

/// Attempts to scan the body for the `previous_body component`, returns FALSE if the body is unable to be scanned, otherwise returns TRUE
/datum/component/soulcatcher/proc/scan_body(mob/living/parent_body, mob/living/user)
	if(!parent_body || !user)
		return FALSE

	var/signal_result = SEND_SIGNAL(parent_body, COMSIG_SOULCATCHER_SCAN_BODY, parent_body)
	if(!signal_result)
		to_chat(user, span_warning("[parent_body] has already been scanned!"))
		return FALSE

	if(istype(parent, /obj/item/handheld_soulcatcher))
		var/obj/item/handheld_soulcatcher/parent_device = parent
		playsound(parent_device, 'monkestation/code/modules/blueshift/sounds/default_good.ogg', 50, FALSE, ignore_walls = FALSE)
		parent_device.visible_message(span_notice("[parent_device] beeps: [parent_body] is now scanned."))

	return TRUE

/// Returns a list containing all of the souls currently present within a soulcatcher.
/datum/component/soulcatcher/proc/get_current_souls()
	var/list/current_souls = list()
	for(var/datum/soulcatcher_room/room as anything in soulcatcher_rooms)
		for(var/mob/living/soulcatcher_soul as anything in room.current_souls)
			current_souls += soulcatcher_soul

	return current_souls

/// Checks the total number of souls present and compares it with `max_souls` returns `TRUE` if there is room (or no limit), otherwise returns `FALSE`
/datum/component/soulcatcher/proc/check_for_vacancy()
	if(!max_souls)
		return TRUE

	if(length(get_current_souls()) >= max_souls)
		return FALSE

	return TRUE

/// Attempts to remove the soulcatcher from the attached object
/datum/component/soulcatcher/proc/remove_self()
	if(!removable)
		return FALSE

	qdel(src)

/**
 * Soulcatcher Room
 *
 * This datum is where souls are sent to when joining soulcatchers.
 * It handles sending messages to souls from the outside along with adding new souls, transfering, and removing souls.
 *
 */
/datum/soulcatcher_room
	/// What is the name of the room?
	var/name = "Default Room"
	/// What is the description of the room?
	var/room_description = "An orange platform suspended in space orbited by reflective cubes of various sizes. There really isn't much here at the moment."
	/// What souls are currently inside of the room?
	var/list/current_souls = list()
	/// Weakref for the master soulcatcher datum
	var/datum/weakref/master_soulcatcher
	/// What is the name of the person sending the messages?
	var/outside_voice = "Host"
	/// Can the room be joined at all?
	var/joinable = TRUE
	/// What is the color of chat messages sent by the room?
	var/room_color = SOULCATCHER_DEFAULT_COLOR

/// Attemps to add a ghost to the soulcatcher room.
/datum/soulcatcher_room/proc/add_soul_from_ghost(mob/dead/observer/ghost)
	if(!ghost || !ghost.ckey)
		return FALSE

	if(!ghost.mind)
		ghost.mind = new /datum/mind(ghost.key)
		ghost.mind.name = ghost.name
		ghost.mind.active = TRUE

	if(!add_soul(ghost.mind))
		return FALSE

	return TRUE

/// Converts a mind into a soul and adds the resulting soul to the room.
/datum/soulcatcher_room/proc/add_soul(datum/mind/mind_to_add)
	if(!mind_to_add)
		return FALSE

	var/datum/component/soulcatcher/parent_soulcatcher = master_soulcatcher.resolve()
	var/datum/parent_object = parent_soulcatcher.parent
	if(!parent_object)
		return FALSE

	var/mob/living/soulcatcher_soul/new_soul = new(parent_object)
	new_soul.name = mind_to_add.name

	if(mind_to_add.current)
		var/datum/component/previous_body/body_component = mind_to_add.current.AddComponent(/datum/component/previous_body)
		body_component.soulcatcher_soul = WEAKREF(new_soul)

		new_soul.round_participant = TRUE
		new_soul.body_scan_needed = TRUE

		new_soul.previous_body = WEAKREF(mind_to_add.current)
		new_soul.name = pick(GLOB.last_names) //Until the body is discovered, the soul is a new person.
		new_soul.soul_desc = "[new_soul] lacks a discernible form."

	mind_to_add.transfer_to(new_soul, TRUE)
	current_souls += new_soul
	new_soul.current_room = WEAKREF(src)

	/*
	var/datum/preferences/preferences = new_soul.client?.prefs
	if(preferences)
		new_soul.ooc_notes = preferences.read_preference(/datum/preference/text/ooc_notes)
		if(!new_soul.body_scan_needed)
			new_soul.soul_desc = preferences.read_preference(/datum/preference/text/flavor_text)
	*/.

	to_chat(new_soul, span_cyan("You find yourself now inside of: [name]"))
	to_chat(new_soul, span_notice(room_description))
	to_chat(new_soul, span_doyourjobidiot("You have entered a soulcatcher, do not share any information you have received while a ghost. If you have died within the round, you do not know your identity until your body has been scanned, standard blackout policy also applies."))
	to_chat(new_soul, span_notice("While inside of a soulcatcher, you are able to speak and emote by using the normal hotkeys and verbs, unless disabled by the owner."))
	to_chat(new_soul, span_notice("You may use the leave soulcatcher verb to leave the soulcatcher and return to your body at any time."))

	var/atom/parent_atom = parent_object
	if(istype(parent_atom))
		var/turf/soulcatcher_turf = get_turf(parent_soulcatcher.parent)
		var/message_to_log = "[key_name(new_soul)] joined [src] inside of [parent_atom] at [loc_name(soulcatcher_turf)]"
		parent_atom.log_message(message_to_log, LOG_GAME)
		new_soul.log_message(message_to_log, LOG_GAME)

	return TRUE

/// Removes a soul from a soulcatcher room, leaving it as a ghost. Returns `FALSE` if the `soul_to_remove` cannot be found, otherwise returns `TRUE` after a successful deletion.
/datum/soulcatcher_room/proc/remove_soul(mob/living/soulcatcher_soul/soul_to_remove)
	if(!soul_to_remove || !(soul_to_remove in current_souls))
		return FALSE

	current_souls -= soul_to_remove
	soul_to_remove.current_room = null

	soul_to_remove.return_to_body()
	qdel(soul_to_remove)

	return TRUE

/// Transfers a soul from a soulcatcher room to another soulcatcher room. Returns `FALSE` if the target room or target soul cannot be found.
/datum/soulcatcher_room/proc/transfer_soul(mob/living/soulcatcher_soul/target_soul, datum/soulcatcher_room/target_room)
	if(!(target_soul in current_souls) || !target_room)
		return FALSE

	var/datum/component/soulcatcher/target_master_soulcatcher = target_room.master_soulcatcher.resolve()
	if(target_master_soulcatcher != master_soulcatcher.resolve())
		target_soul.forceMove(target_master_soulcatcher.parent)

	target_soul.current_room = WEAKREF(target_room)
	current_souls -= target_soul
	target_room.current_souls += target_soul

	to_chat(target_soul, span_cyan("you've been transferred to [target_room]!"))
	to_chat(target_soul, span_notice(target_room.room_description))

	return TRUE

/**
 * Sends a message or emote to all of the souls currently located inside of the soulcatcher room. Returns `FALSE` if a message cannot be sent, otherwise returns `TRUE`.
 *
 * Arguments
 * * message_to_send - The message we want to send to the occupants of the room
 * * message_sender - The person that is sending the message. This is not required.
 * * emote - Is the message sent an emote or not?
 */
/datum/soulcatcher_room/proc/send_message(message_to_send, message_sender, emote = FALSE)
	if(!message_to_send) //Why say nothing?
		return FALSE

	var/datum/asset/spritesheet_batched/chat/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
	var/tag = sheet.icon_tag("nif-soulcatcher")
	var/soulcatcher_icon = ""

	if(tag)
		soulcatcher_icon = tag

	var/mob/living/soulcatcher_soul/soul_sender = message_sender
	if(istype(soul_sender) && soul_sender.communicating_externally)
		var/master_resolved = master_soulcatcher.resolve()
		if(!master_resolved)
			return FALSE
		var/datum/component/soulcatcher/parent_soulcatcher = master_resolved
		var/obj/item/parent_object = parent_soulcatcher.parent
		if(!istype(parent_object))
			return FALSE

		var/temp_name = parent_object.name
		parent_object.name = "[parent_object.name] [soulcatcher_icon]"

		if(emote)
			parent_object.manual_emote(html_decode(message_to_send))
			log_emote("[soul_sender] in [name] soulcatcher room emoted: [message_to_send], as an external object")
		else
			parent_object.say(html_decode(message_to_send))
			log_say("[soul_sender] in [name] soulcatcher room said: [message_to_send], as an external object")

		parent_object.name = temp_name
		return TRUE

	var/sender_name = ""
	if(message_sender)
		sender_name = "[message_sender] "

	var/first_room_name_word = splittext(name, " ")
	var/message = ""
	var/owner_message = ""
	if(!emote)
		message = "<font color=[room_color]>\ [soulcatcher_icon] <b>[sender_name]</b>says, \"[message_to_send]\"</font>"
		owner_message = "<font color=[room_color]>\ <b>([first_room_name_word[1]])</b> [soulcatcher_icon] <b>[sender_name]</b>says, \"[message_to_send]\"</font>"
		log_say("[sender_name] in [name] soulcatcher room said: [message_to_send]")
	else
		message = "<font color=[room_color]>\ [soulcatcher_icon] <b>[sender_name]</b>[message_to_send]</font>"
		owner_message = "<font color=[room_color]>\ <b>([first_room_name_word[1]])</b> [soulcatcher_icon] <b>[sender_name]</b>[message_to_send]</font>"
		log_emote("[sender_name] in [name] soulcatcher room emoted: [message_to_send]")

	for(var/mob/living/soulcatcher_soul/soul as anything in current_souls)
		if((emote && !soul.internal_sight) || (!emote && !soul.internal_hearing))
			continue

		to_chat(soul, message)

	relay_message_to_soulcatcher(owner_message)
	return TRUE

/// Relays a message sent from the send_message proc to the parent soulcatcher datum
/datum/soulcatcher_room/proc/relay_message_to_soulcatcher(message)
	if(!message)
		return FALSE

	var/datum/component/soulcatcher/recepient_soulcatcher = master_soulcatcher.resolve()
	recepient_soulcatcher.receive_message(message)
	return TRUE

/datum/soulcatcher_room/Destroy(force)
	for(var/mob/living/soulcatcher_soul/soul as anything in current_souls)
		remove_soul(soul)

	return ..()

/datum/action/innate/join_soulcatcher
	name = "Enter Soulcatcher"
	background_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/action_backgrounds.dmi'
	background_icon_state = "android"
	button_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/actions_nif.dmi'
	button_icon_state = "soulcatcher_enter"

/datum/action/innate/join_soulcatcher/Activate()
	. = ..()
	var/mob/dead/observer/joining_soul = owner
	if(!joining_soul)
		return FALSE

	joining_soul.join_soulcatcher()

/mob/dead/observer/verb/join_soulcatcher()
	set name = "Enter Soulcatcher"
	set category = "Ghost"

	var/list/joinable_soulcatchers = list()
	for(var/datum/component/soulcatcher/soulcatcher in GLOB.soulcatchers)
		if(!soulcatcher.ghost_joinable || !isobj(soulcatcher.parent) || !soulcatcher.check_for_vacancy())
			continue

		var/obj/item/soulcatcher_parent = soulcatcher.parent
		if(soulcatcher.name != soulcatcher_parent.name)
			soulcatcher.name = soulcatcher_parent.name

		joinable_soulcatchers += soulcatcher

	if(!length(joinable_soulcatchers))
		to_chat(src, span_warning("No soulcatchers are joinable."))
		return FALSE

	var/datum/component/soulcatcher/soulcatcher_to_join = tgui_input_list(src, "Choose a soulcatcher to join", "Enter a soulcatcher", joinable_soulcatchers)
	if(!soulcatcher_to_join || !(soulcatcher_to_join in joinable_soulcatchers))
		return FALSE

	var/list/rooms_to_join = list()
	for(var/datum/soulcatcher_room/room in soulcatcher_to_join.soulcatcher_rooms)
		if(!room.joinable)
			continue

		rooms_to_join += room

	var/datum/soulcatcher_room/room_to_join
	if(length(rooms_to_join) < 1)
		to_chat(src, span_warning("There no rooms that you can join."))
		return FALSE

	if(length(rooms_to_join) == 1)
		room_to_join = rooms_to_join[1]

	else
		room_to_join = tgui_input_list(src, "Choose a room to enter", "Enter a room", rooms_to_join)

	if(!room_to_join)
		to_chat(src, span_warning("There no rooms that you can join."))
		return FALSE

	if(soulcatcher_to_join.require_approval)
		var/ghost_name = name
		if(mind?.current)
			ghost_name = "unknown"

		if(!soulcatcher_to_join.get_approval(ghost_name))
			to_chat(src, span_warning("The owner of [soulcatcher_to_join.name] declined your request to join."))
			return FALSE

	room_to_join.add_soul_from_ghost(src)
	return TRUE

/mob/grab_ghost(force)
	SEND_SIGNAL(src, COMSIG_SOULCATCHER_CHECK_SOUL)
	return ..()

/mob/get_ghost(even_if_they_cant_reenter, ghosts_with_clients)
	if(GetComponent(/datum/component/previous_body)) //Is the soul currently within a soulcatcher?
		return TRUE

	return ..()

/mob/dead/observer/Login()
	. = ..()
	var/datum/preferences/preferences = client?.prefs
	var/soulcatcher_action_given

	if(preferences)
		soulcatcher_action_given = preferences.read_preference(/datum/preference/toggle/soulcatcher_join_action)

	if(!soulcatcher_action_given)
		return

	if(locate(/datum/action/innate/join_soulcatcher) in actions)
		return

	var/datum/action/innate/join_soulcatcher/new_join_action = new(src)
	new_join_action.Grant(src)

/datum/component/soulcatcher/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(usr, src, ui)

	if(!ui)
		ui = new(usr, src, "Soulcatcher", name)
		ui.open()

/datum/component/soulcatcher/nifsoft/ui_state(mob/user)
	return GLOB.conscious_state

/datum/component/soulcatcher/ui_data(mob/user)
	var/list/data = list()

	data["ghost_joinable"] = ghost_joinable
	data["require_approval"] = require_approval
	data["theme"] = ui_theme
	data["communicate_as_parent"] = communicate_as_parent
	data["current_soul_count"] = length(get_current_souls())
	data["max_souls"] = max_souls
	data["removable"] = removable

	data["current_rooms"] = list()
	for(var/datum/soulcatcher_room/room in soulcatcher_rooms)
		var/currently_targeted = (room == targeted_soulcatcher_room)

		var/list/room_data = list(
		"name" = html_decode(room.name),
		"description" = html_decode(room.room_description),
		"reference" = REF(room),
		"joinable" = room.joinable,
		"color" = room.room_color,
		"currently_targeted" = currently_targeted,
		)

		for(var/mob/living/soulcatcher_soul/soul in room.current_souls)
			var/list/soul_list = list(
				"name" = soul.name,
				"description" = soul.soul_desc,
				"reference" = REF(soul),
				"internal_hearing" = soul.internal_hearing,
				"internal_sight" = soul.internal_sight,
				"outside_hearing" = soul.outside_hearing,
				"outside_sight" = soul.outside_sight,
				"able_to_emote" = soul.able_to_emote,
				"able_to_speak" = soul.able_to_speak,
				"able_to_rename" = soul.able_to_rename,
				"ooc_notes" = soul.ooc_notes,
				"scan_needed" = soul.body_scan_needed,
				"able_to_speak_as_container" = soul.able_to_speak_as_container,
				"able_to_emote_as_container" = soul.able_to_emote_as_container,
			)
			room_data["souls"] += list(soul_list)

		data["current_rooms"] += list(room_data)

	return data

/datum/component/soulcatcher/ui_static_data(mob/user)
	var/list/data = list()

	data["current_vessel"] = parent

	return data

/datum/component/soulcatcher/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/datum/soulcatcher_room/target_room
	if(params["room_ref"])
		target_room = locate(params["room_ref"]) in soulcatcher_rooms
		if(!target_room)
			return FALSE

	var/mob/living/soulcatcher_soul/target_soul
	if(params["target_soul"])
		target_soul = locate(params["target_soul"]) in target_room.current_souls
		if(!target_soul)
			return FALSE

	switch(action)
		if("delete_room")
			if(length(soulcatcher_rooms) <= 1)
				return FALSE

			soulcatcher_rooms -= target_room
			targeted_soulcatcher_room = soulcatcher_rooms[1]
			qdel(target_room)
			return TRUE

		if("change_targeted_room")
			targeted_soulcatcher_room = target_room
			return TRUE

		if("create_room")
			create_room()
			return TRUE

		if("rename_room")
			var/new_room_name = tgui_input_text(usr,"Choose a new name for the room", name, target_room.name)
			if(!new_room_name)
				return FALSE

			target_room.name = new_room_name
			return TRUE

		if("redescribe_room")
			var/new_room_desc = tgui_input_text(usr,"Choose a new description for the room", name, target_room.room_description, multiline = TRUE)
			if(!new_room_desc)
				return FALSE

			target_room.room_description = new_room_desc
			return TRUE

		if("toggle_joinable_room")
			target_room.joinable = !target_room.joinable
			return TRUE

		if("toggle_joinable")
			ghost_joinable = !ghost_joinable
			return TRUE

		if("toggle_approval")
			require_approval = !require_approval
			return TRUE

		if("modify_name")
			var/new_name = tgui_input_text(usr,"Choose a new name to send messages as", name, target_room.outside_voice, multiline = TRUE)
			if(!new_name)
				return FALSE

			target_room.outside_voice = new_name
			return TRUE

		if("remove_soul")
			target_room.remove_soul(target_soul)
			return TRUE

		if("transfer_soul")
			var/list/available_rooms = soulcatcher_rooms.Copy()
			available_rooms -= target_room

			if(ishuman(usr))
				var/mob/living/carbon/human/human_user = usr
				var/datum/nifsoft/soulcatcher/soulcatcher_nifsoft = human_user.find_nifsoft(/datum/nifsoft/soulcatcher)
				if(soulcatcher_nifsoft && (parent != soulcatcher_nifsoft.parent_nif.resolve()))
					var/datum/component/soulcatcher/nifsoft_soulcatcher = soulcatcher_nifsoft.linked_soulcatcher.resolve()
					if(istype(nifsoft_soulcatcher))
						available_rooms.Add(nifsoft_soulcatcher.soulcatcher_rooms)

				for(var/obj/item/held_item in human_user.held_items)
					if(parent == held_item)
						continue

					var/datum/component/soulcatcher/soulcatcher_component = held_item.GetComponent(/datum/component/soulcatcher)
					if(!soulcatcher_component || !soulcatcher_component.check_for_vacancy())
						continue

					for(var/datum/soulcatcher_room/room in soulcatcher_component.soulcatcher_rooms)
						available_rooms += room

			var/datum/soulcatcher_room/transfer_room = tgui_input_list(usr, "Choose a room to transfer to", name, available_rooms)
			if(!(transfer_room in available_rooms))
				return FALSE

			target_room.transfer_soul(target_soul, transfer_room)
			return TRUE

		if("change_room_color")
			var/new_room_color = tgui_color_picker(usr, "", "Choose Color", SOULCATCHER_DEFAULT_COLOR)
			if(!new_room_color)
				return FALSE

			target_room.room_color = new_room_color

		if("toggle_soul_outside_sense")
			if(params["sense_to_change"] == "hearing")
				target_soul.toggle_hearing()
			else
				target_soul.toggle_sight()

			return TRUE

		if("toggle_soul_sense")
			if(params["sense_to_change"] == "hearing")
				target_soul.internal_hearing = !target_soul.internal_hearing
			else
				target_soul.internal_sight = !target_soul.internal_sight

			return TRUE

		if("toggle_soul_communication")
			if(params["communication_type"] == "emote")
				target_soul.able_to_emote = !target_soul.able_to_emote
			else
				target_soul.able_to_speak = !target_soul.able_to_speak

			return TRUE

		if("toggle_soul_external_communication")
			if(params["communication_type"] == "emote")
				target_soul.able_to_emote_as_container = !target_soul.able_to_emote_as_container
			else
				target_soul.able_to_speak_as_container = !target_soul.able_to_speak_as_container

			return TRUE

		if("toggle_soul_renaming")
			target_soul.able_to_rename = !target_soul.able_to_rename
			return TRUE

		if("change_name")
			var/new_name = tgui_input_text(usr, "Enter a new name for [target_soul]", "Soulcatcher", target_soul)
			if(!new_name)
				return FALSE

			target_soul.change_name(new_name)
			return TRUE

		if("reset_name")
			if(tgui_alert(usr, "Do you wish to reset [target_soul]'s name to default?", "Soulcatcher", list("Yes", "No")) != "Yes")
				return FALSE

			target_soul.reset_name()

		if("send_message")
			var/message_to_send = ""
			var/emote = params["emote"]
			var/message_sender = target_room.outside_voice
			if(params["narration"])
				message_sender = FALSE

			message_to_send = tgui_input_text(usr, "Input the message you want to send", name, multiline = TRUE)

			if(!message_to_send)
				return FALSE

			target_room.send_message(message_to_send, message_sender, emote)
			return TRUE

		if("delete_self")
			if(tgui_alert(usr, "Are you sure you want to detach the soulcatcher?", parent, list("Yes", "No")) != "Yes")
				return FALSE

			remove_self()
			return TRUE

/datum/component/soulcatcher_user/New()
	. = ..()
	var/mob/living/soulcatcher_soul/parent_soul = parent
	if(!istype(parent_soul))
		return COMPONENT_INCOMPATIBLE

	return TRUE

/datum/component/soulcatcher_user/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(usr, src, ui)
	if(!ui)
		ui = new(usr, src, "SoulcatcherUser")
		ui.open()

/datum/component/soulcatcher_user/ui_state(mob/user)
	return GLOB.conscious_state

/datum/component/soulcatcher_user/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/soulcatcher_soul/user_soul = parent
	if(!istype(user_soul))
		return FALSE //uhoh

	data["user_data"] = list(
		"name" = user_soul.name,
		"description" = user_soul.soul_desc,
		"reference" = REF(user_soul),
		"internal_hearing" = user_soul.internal_hearing,
		"internal_sight" = user_soul.internal_sight,
		"outside_hearing" = user_soul.outside_hearing,
		"outside_sight" = user_soul.outside_sight,
		"able_to_emote" = user_soul.able_to_emote,
		"able_to_speak" = user_soul.able_to_speak,
		"able_to_rename" = user_soul.able_to_rename,
		"able_to_speak_as_container" = user_soul.able_to_speak_as_container,
		"able_to_emote_as_container" = user_soul.able_to_emote_as_container,
		"communicating_externally" = user_soul.communicating_externally,
		"ooc_notes" = user_soul.ooc_notes,
		"scan_needed" = user_soul.body_scan_needed,
	)

	var/datum/soulcatcher_room/current_room = user_soul.current_room.resolve()
	data["current_room"] = list(
		"name" = html_decode(current_room.name),
		"description" = html_decode(current_room.room_description),
		"reference" = REF(current_room),
		"color" = current_room.room_color,
		"owner" = current_room.outside_voice,
		)

	var/datum/component/soulcatcher/master_soulcatcher = current_room.master_soulcatcher.resolve()
	data["communicate_as_parent"] = master_soulcatcher.communicate_as_parent

	for(var/mob/living/soulcatcher_soul/soul in current_room.current_souls)
		if(soul == user_soul)
			continue

		var/list/soul_list = list(
			"name" = soul.name,
			"description" = soul.soul_desc,
			"ooc_notes" = soul.ooc_notes,
			"reference" = REF(soul),
		)
		data["souls"] += list(soul_list)

	return data

/datum/component/soulcatcher_user/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/living/soulcatcher_soul/user_soul = parent
	if(!istype(user_soul))
		return FALSE

	switch(action)
		if("change_name")
			var/new_name = tgui_input_text(usr, "Enter a new name", "Soulcatcher", user_soul.name)
			if(!new_name)
				return FALSE

			user_soul.change_name(new_name)
			return TRUE

		if("reset_name")
			if(tgui_alert(usr, "Do you wish to reset your name to default?", "Soulcatcher", list("Yes", "No")) != "Yes")
				return FALSE

			user_soul.reset_name()

		if("toggle_external_communication")
			user_soul.communicating_externally = !user_soul.communicating_externally
			return TRUE
