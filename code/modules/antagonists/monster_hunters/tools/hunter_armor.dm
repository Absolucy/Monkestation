/datum/armor/queens_huntsman
	melee = 55
	bullet = 35
	laser = 35
	energy = 50
	bomb = 35
	wound = 45
	bio = 100
	fire = 50 // monster hunters and burning monsters, name a better combo
	acid = 100

/obj/item/clothing/head/hats/queens_huntsman
	name = "Mad Hunter's Hat"
	desc = "A weathered leather hat worn by the Queen's monster hunters."
	icon_state = "queens_huntsman"
	armor_type = /datum/armor/queens_huntsman
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	strip_delay = 8 SECONDS

/obj/item/clothing/suit/armor/queens_huntsman
	name = "Mad Hunter's Frockcoat"
	desc = "A long leather hunting coat with a reinforced shoulder cape."
	icon_state = "queens_huntsman"
	inhand_icon_state = "armor"
	body_parts_covered = CHEST | GROIN | ARMS | LEGS
	armor_type = /datum/armor/queens_huntsman
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | BLOCKS_SHOVE_KNOCKDOWN
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	strip_delay = 10 SECONDS
	allowed = list(
		/obj/item/blood_vial,
		/obj/item/grenade/jack,
		/obj/item/melee/trick_weapon,
		/obj/item/rabbit_locator,
		/obj/item/stake,
	)

/obj/item/clothing/suit/armor/queens_huntsman/build_worn_icon(
	default_layer = 0,
	default_icon_file = null,
	isinhands = FALSE,
	female_uniform = NO_FEMALE_UNIFORM,
	override_state = null,
	override_file = null,
)
	var/mob/living/carbon/human/wearer = loc
	if(!isinhands && istype(wearer) && wearer.physique != MALE)
		override_state = "queens_huntsman_f"
	return ..()

/obj/item/clothing/under/costume/queens_huntsman
	name = "Waistcoat of Hearts"
	desc = "A fitted undercoat and trousers worn beneath a monster hunter's armor."
	icon_state = "queens_huntsman"
	inhand_icon_state = null
	armor_type = /datum/armor/queens_huntsman
	can_adjust = FALSE
	has_sensor = NO_SENSORS
	random_sensor = FALSE
	female_sprite_flags = NO_FEMALE_UNIFORM
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	strip_delay = 10 SECONDS

/obj/item/clothing/under/costume/queens_huntsman/build_worn_icon(
	default_layer = 0,
	default_icon_file = null,
	isinhands = FALSE,
	female_uniform = NO_FEMALE_UNIFORM,
	override_state = null,
	override_file = null,
)
	var/mob/living/carbon/human/wearer = loc
	if(!isinhands && istype(wearer) && wearer.physique != MALE)
		override_state = "queens_huntsman_f"
	return ..()

/obj/item/clothing/gloves/queens_huntsman
	name = "Teastained Gloves"
	desc = "Brown leather gloves that keep a hunter's hands protected."
	icon_state = "queens_huntsman"
	worn_icon = 'icons/mob/clothing/hands.dmi'
	armor_type = /datum/armor/queens_huntsman
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	siemens_coefficient = 0
	strip_delay = 8 SECONDS

/obj/item/clothing/gloves/queens_huntsman/red
	name = "Red-Handed Gloves"
	desc = "Red leather gloves that keep a hunter's hands protected."
	icon_state = "queens_huntsman_red"

/obj/item/clothing/shoes/queens_huntsman
	name = "Rabbit-Hole Boots"
	desc = "Sturdy leather boots for tracking monsters through the night."
	icon_state = "queens_huntsman"
	inhand_icon_state = "jackboots"
	worn_icon = 'icons/mob/clothing/feet.dmi'
	armor_type = /datum/armor/queens_huntsman
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	supports_variations_flags = CLOTHING_DIGITIGRADE_MASK
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	strip_delay = 8 SECONDS

/obj/item/clothing/shoes/queens_huntsman/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/shoes)
