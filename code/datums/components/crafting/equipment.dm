/datum/crafting_recipe/strobeshield
	name = "Strobe Shield"
	result = /obj/item/shield/riot/flash
	reqs = list(
		/obj/item/wallframe/flasher = 1,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/shield/riot = 1,
	)
	time = 4 SECONDS
	category = CAT_EQUIPMENT

/datum/crafting_recipe/strobeshield/New()
	..()
	blacklist |= subtypesof(/obj/item/shield/riot)

/datum/crafting_recipe/radiogloves
	name = "Radio Gloves"
	result = /obj/item/clothing/gloves/radio
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/radio = 1,
	)
	tool_behaviors = list(TOOL_WIRECUTTER)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/radiogloves/New()
	..()
	blacklist |= typesof(/obj/item/radio/headset)
	blacklist |= typesof(/obj/item/radio/intercom)

/datum/crafting_recipe/wheelchair
	name = "Wheelchair"
	result = /obj/vehicle/ridden/wheelchair
	reqs = list(
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/rods = 6,
	)
	time = 10 SECONDS
	category = CAT_EQUIPMENT

/datum/crafting_recipe/motorized_wheelchair
	name = "Motorized Wheelchair"
	result = /obj/vehicle/ridden/wheelchair/motorized
	reqs = list(
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/rods = 8,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1,
	)
	parts = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1,
	)
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 20 SECONDS
	category = CAT_EQUIPMENT

/datum/crafting_recipe/freezer_cabinat
	name = "Freezer Cabinet"
	result = /obj/structure/closet/secure_closet/freezer/empty
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/assembly/igniter/condenser = 1,
	)
	time = 5 SECONDS
	category = CAT_EQUIPMENT

/datum/crafting_recipe/trapdoor_kit
	name = "Trapdoor Construction Kit"
	result = /obj/item/trapdoor_kit
	reqs = list(
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/rods = 4,
		/obj/item/stack/cable_coil = 10,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/assembly/signaler = 1,
	)
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	time = 10 SECONDS
	category = CAT_EQUIPMENT

/datum/crafting_recipe/trapdoor_remote
	name = "Trapdoor Remote"
	result = /obj/item/trapdoor_remote/preloaded // since its useless without its assembly just require an assembly to craft it
	reqs = list(
		/obj/item/compact_remote = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/assembly/trapdoor = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 5 SECONDS
	category = CAT_EQUIPMENT

/datum/crafting_recipe/mousetrap
	name = "Mouse Trap"
	result = /obj/item/assembly/mousetrap
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/sheet/cardboard = 1,
		/obj/item/stack/rods = 1,
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/flashlight_eyes
	name = "Flashlight Eyes"
	result = /obj/item/organ/internal/eyes/robotic/flashlight
	time = 10
	reqs = list(
		/obj/item/flashlight = 2,
		/obj/item/restraints/handcuffs/cable = 1
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/extendohand_r
	name = "Extendo-Hand (Right Arm)"
	reqs = list(
		/obj/item/bodypart/arm/right/robot = 1,
		/obj/item/clothing/gloves/boxing = 1,
	)
	result = /obj/item/extendohand
	category = CAT_EQUIPMENT

/datum/crafting_recipe/extendohand_l
	name = "Extendo-Hand (Left Arm)"
	reqs = list(
		/obj/item/bodypart/arm/left/robot = 1,
		/obj/item/clothing/gloves/boxing = 1,
	)
	result = /obj/item/extendohand
	category = CAT_EQUIPMENT

/datum/crafting_recipe/ore_sensor
	name = "Ore Sensor"
	time = 3 SECONDS
	reqs = list(
		/datum/reagent/brimdust = 15,
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/sheet/sinew = 1,
	)
	result = /obj/item/ore_sensor
	category = CAT_EQUIPMENT

/datum/crafting_recipe/pressureplate
	name = "Pressure Plate"
	result = /obj/item/pressure_plate
	time = 0.5 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/tile/iron = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/assembly/igniter = 1,
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/rcl
	name = "Makeshift Rapid Pipe Cleaner Layer"
	result = /obj/item/rcl/ghetto
	time = 4 SECONDS
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(/obj/item/stack/sheet/iron = 15)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/ghettojetpack
	name = "Improvised Jetpack"
	result = /obj/item/tank/jetpack/improvised
	time = 30
	reqs = list(
		/obj/item/tank/internals/oxygen = 2,
		/obj/item/extinguisher = 1,
		/obj/item/pipe = 3,
		/obj/item/stack/cable_coil = MAXCOIL,
	)
	category = CAT_EQUIPMENT
	tool_behaviors = list(TOOL_WRENCH, TOOL_WELDER, TOOL_WIRECUTTER)

/datum/crafting_recipe/gripperoffbrand
	name = "Improvised Gripper Gloves"
	reqs = list(
		/obj/item/clothing/gloves/fingerless = 1,
		/obj/item/stack/sticky_tape = 1,
	)
	result = /obj/item/clothing/gloves/tackler/offbrand
	category = CAT_EQUIPMENT

/**
 * Recipe used for upgrading fake N-spect scanners to bananium HONK-spect scanners
 */
/datum/crafting_recipe/clown_scanner_upgrade
	name = "Bananium HONK-spect scanner"
	result = /obj/item/inspector/clown/bananium
	reqs = list(
		/obj/item/inspector/clown = 1,
		/obj/item/stack/sticky_tape = 3,
		/obj/item/stack/sheet/mineral/bananium = 5,
	) //the chainsaw of prank tools
	tool_paths = list(/obj/item/bikehorn)
	time = 40 SECONDS
	category = CAT_EQUIPMENT

/datum/crafting_recipe/rebar_quiver
	name = "Rebar Storage Quiver"
	result = /obj/item/storage/bag/rebar_quiver
	time = 10
	reqs = list(
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/stack/cable_coil = 15,
	)
	category = CAT_EQUIPMENT
	tool_behaviors = list(TOOL_WELDER, TOOL_WIRECUTTER)

/datum/crafting_recipe/umbrella
	name = "Umbrella"
	result = /obj/item/umbrella
	reqs = list(
		/obj/item/stack/sheet/cloth = 3,
		/obj/item/stack/rods = 1,
	)
	tool_behaviors = list(TOOL_CROWBAR)
	time = 5 SECONDS
	category = CAT_EQUIPMENT
