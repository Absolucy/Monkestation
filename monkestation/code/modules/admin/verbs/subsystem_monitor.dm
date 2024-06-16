GLOBAL_DATUM(subsystem_monitor_ui, /datum/subsystem_monitor_ui)

/datum/subsystem_monitor_ui

/datum/subsystem_monitor_ui/ui_interact(mob/user, datum/tgui/ui)
	if(!check_rights_for(user.client, R_DEBUG))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SubsystemProfiler")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/subsystem_monitor_ui/ui_status(mob/user, datum/ui_state/state)
	return check_rights_for(user.client, R_DEBUG) ? UI_INTERACTIVE : UI_CLOSE

/datum/subsystem_monitor_ui/ui_data(mob/user)
	var/list/subsystems = list()
	for(var/datum/controller/subsystem/subsystem as anything in Master.subsystems)
		subsystems += list(list(
			"name" = subsystem.name,
			"path" = "[subsystem.type]",
			"wait" = subsystem.wait,
			"priority" = subsystem.priority,
			"state" = subsystem.state,
			"focused" = subsystem.profiler_focused,
			"cost" = subsystem.cost,
			"tick_usage" = subsystem.tick_usage,
			"tick_overrun" = subsystem.tick_overrun,
			"ticks" = subsystem.ticks,
		))
	return list("subsystems" = subsystems)

/datum/subsystem_monitor_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_DEBUG))
		return
	switch(action)
		if("set_focus")
			var/subsystem_path = text2path(params["subsystem"])
			var/new_focus = params["focus"]
			if(isnull(subsystem_path) || isnull(new_focus))
				return
			if(!ispath(subsystem_path, /datum/controller/subsystem))
				stack_trace("Attemped to focus non-subsystem [subsystem_path]!")
				return
			var/datum/controller/subsystem/subsystem = locate(subsystem_path) in Master.subsystems
			if(!subsystem)
				stack_trace("Subsystem [subsystem_path] not found in MC!")
				return
			message_admins("[key_name(usr)] [new_focus ? "focused" : "unfocused"] the profiler on [subsystem.name] ([subsystem_path])")
			log_admin("[key_name(usr)] [new_focus ? "focused" : "unfocused"] the profiler on [subsystem.name] ([subsystem_path])")
			subsystem.profiler_focused = new_focus
			return TRUE


/client/proc/subsystem_monitor()
	set name = "Subsystem Monitor"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return
	if(!GLOB.subsystem_monitor_ui)
		GLOB.subsystem_monitor_ui = new
	GLOB.subsystem_monitor_ui.ui_interact(usr)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Subsystem Monitor") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
