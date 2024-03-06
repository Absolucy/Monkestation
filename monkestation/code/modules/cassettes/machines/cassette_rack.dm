#define MAX_STORED_CASSETTES 		28
#define DEFAULT_CASSETTES_TO_SPAWN 	5
#define DEFAULT_BLANKS_TO_SPAWN 	10

/obj/structure/cassette_rack
	name = "cassette pouch"
	desc = "Safely holds cassettes for storage."
	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "cassette_pouch"
	anchored = FALSE
	density = FALSE

/obj/structure/cassette_rack/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/cassette_rack)

/obj/structure/cassette_rack/update_overlays()
	. = ..()
	var/number = length(contents) ? CEILING(length(contents) / 7, 1) : 0
	. += mutable_appearance(icon, "[icon_state]_[number]")

/datum/storage/cassette_rack
	can_hold = list(/obj/item/device/cassette_tape)
	max_slots = MAX_STORED_CASSETTES
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = WEIGHT_CLASS_SMALL * MAX_STORED_CASSETTES
	quickdraw = TRUE
	numerical_stacking = TRUE

/obj/structure/cassette_rack/prefilled
	var/spawn_random = DEFAULT_CASSETTES_TO_SPAWN
	var/spawn_blanks = DEFAULT_BLANKS_TO_SPAWN

/obj/structure/cassette_rack/prefilled/Initialize(mapload)
	. = ..()
	for(var/i in 1 to spawn_blanks)
		new /obj/item/device/cassette_tape/blank(src)
	for(var/id in unique_random_tapes(spawn_random))
		new /obj/item/device/cassette_tape(src, id)

#undef DEFAULT_BLANKS_TO_SPAWN
#undef DEFAULT_CASSETTES_TO_SPAWN
#undef MAX_STORED_CASSETTES
