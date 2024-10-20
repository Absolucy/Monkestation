/datum/controller/subsystem/profiler/stat_entry(msg)
	msg += "F:[round(fetch_cost, 1)]ms"
	msg += "|W:[round(write_cost, 1)]ms"
	return msg

/datum/controller/subsystem/profiler/proc/DumpFile()
	var/timer = TICK_USAGE_REAL
	var/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
	var/current_sendmaps_data = world.Profile(PROFILE_REFRESH, type = "sendmaps", format = "json")
	fetch_cost = MC_AVERAGE(fetch_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	CHECK_TICK

	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")

	var/timestamp = time2text(world.timeofday, "YYYY-MM-DD_hh-mm-ss")
	var/prof_file = "[GLOB.log_directory]/profiler/profiler-[timestamp].json"
	if(!length(current_sendmaps_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, sendmaps profiling stopped manually before dump.")
	var/sendmaps_file = "[GLOB.log_directory]/profiler/sendmaps-[timestamp].json"

	timer = TICK_USAGE_REAL
	aneri_file_write(current_profile_data, prof_file)
	aneri_file_write(current_sendmaps_data, sendmaps_file)
	write_cost = MC_AVERAGE(write_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

/datum/controller/subsystem/profiler/get_metrics()
	. = ..()
	.["custom"] = list(
		"fetch_cost" = fetch_cost,
		"sort_cost" = 0,
		"write_cost" = write_cost,
	)
