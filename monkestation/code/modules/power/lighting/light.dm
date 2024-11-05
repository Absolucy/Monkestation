#define LIGHT_ALARM_UPDATE_COOLDOWN (1.5 SECONDS)

/obj/machinery/light
	/// Cooldown for updating whenever the room's fire alarm status changes, to hopefully prevent weird situations?
	COOLDOWN_DECLARE(alarm_update_cooldown)

/obj/machinery/light/proc/handle_fire(area/source, new_fire)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, alarm_update_cooldown))
		addtimer(CALLBACK(src, PROC_REF(handle_fire_update)), COOLDOWN_TIMELEFT(src, alarm_update_cooldown), TIMER_UNIQUE)
		return
	handle_fire_update()

/// Wrapper proc to start the refresh_cooldown when updating due to a fire alarm.
/obj/machinery/light/proc/handle_fire_update()
	update(force = TRUE)
	COOLDOWN_START(src, alarm_update_cooldown, LIGHT_ALARM_UPDATE_COOLDOWN)

#undef LIGHT_ALARM_UPDATE_COOLDOWN
