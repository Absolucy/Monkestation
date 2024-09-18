/// Ensures that none of the random centcom arenas have active turfs when loaded
/datum/unit_test/arena_active_turfs
	priority = TEST_LONGER
	var/base_x = 1
	var/base_y = 1
	var/base_z = 1

/datum/unit_test/arena_active_turfs/Run()
	base_x = run_loc_floor_bottom_left.x
	base_y = run_loc_floor_bottom_left.y
	base_z = run_loc_floor_bottom_left.z
	for(var/datum/map_template/random_room/random_arena/arena_path as anything in typesof(/datum/map_template/random_room/random_arena))
		var/room_id = arena_path::room_id
		if(!room_id)
			continue
		var/datum/map_template/random_room/random_arena/arena = SSmapping.map_templates[room_id]
		if(!arena)
			TEST_FAIL("[arena_path] not in SSmapping.map_templates!")
			continue
		// Clear all tiles in the arena, and reset the turfs.
		for(var/turf/turf in get_template_turfs())
			turf.empty(
				turf_type = /turf/open/indestructible/event/plating,
				baseturf_type = /turf/open/indestructible/event/plating,
				flags = CHANGETURF_IGNORE_AIR
			)
		arena.load(run_loc_floor_bottom_left, centered = arena.centerspawner)
		for(var/turf/open/open_turf in get_template_turfs())
			var/turf_loc = "[open_turf.type] ([open_turf.x - base_x + 1], [open_turf.y - base_y + 1])"
			if(open_turf.initial_gas_mix != OPENTURF_DEFAULT_ATMOS)
				TEST_FAIL("Non-default initial_gas_mix in [arena_path] on [turf_loc]")

/// Returns the block of turfs to fit the arena.
/// This assumes that all arenas have the same width/height,
/// which should be a reasonable assumption. Hopefully.
/datum/unit_test/arena_active_turfs/proc/get_template_turfs() as /list
	RETURN_TYPE(/list)
	var/width = /datum/map_template/random_room/random_arena::template_width
	var/height = /datum/map_template/random_room/random_arena::template_height
	return block(base_x, base_y, base_z, width + base_x, height + base_y, base_z)
