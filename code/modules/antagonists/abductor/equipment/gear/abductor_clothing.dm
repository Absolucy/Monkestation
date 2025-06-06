/obj/item/clothing/under/abductor
	desc = "The most advanced form of jumpsuit known to reality, looks uncomfortable."
	name = "alien jumpsuit"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "abductor"
	inhand_icon_state = "bl_suit"
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	armor_type = /datum/armor/under_abductor
	can_adjust = FALSE

/datum/armor/under_abductor
	bomb = 10
	bio = 10
	wound = 5

//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "agent vest"
	desc = "A vest outfitted with advanced stealth technology. It has two modes - combat and stealth."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_stealth"
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	armor_type = /datum/armor/abductor_vest
	actions_types = list(/datum/action/item_action/hands_free/activate)
	allowed = list(
		/obj/item/abductor,
		/obj/item/melee/baton,
		/obj/item/gun/energy,
		/obj/item/restraints/handcuffs,
	)
	/// What operation mode is our vest in?
	var/mode = VEST_STEALTH
	/// Do we have a disguise active?
	var/stealth_active = FALSE
	/// Cooldown in seconds for the combat mode activation stimulant.
	var/combat_cooldown = 20
	/// The visual of our suit's disguise.
	var/datum/icon_snapshot/disguise

/datum/armor/abductor_combat
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	bio = 50
	fire = 90
	acid = 90

/datum/armor/abductor_vest
	melee = 15
	bullet = 15
	laser = 15
	energy = 25
	bomb = 15
	bio = 15
	fire = 70
	acid = 70

/obj/item/clothing/suit/armor/abductor/vest/proc/toggle_nodrop()
	if(HAS_TRAIT_FROM(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT))
		REMOVE_TRAIT(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	else
		ADD_TRAIT(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	if(ismob(loc))
		to_chat(loc, span_notice("Your vest is now [HAS_TRAIT_FROM(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT) ? "locked" : "unlocked"]."))

/obj/item/clothing/suit/armor/abductor/vest/proc/flip_mode()
	switch(mode)
		if(VEST_STEALTH)
			mode = VEST_COMBAT
			DeactivateStealth()
			set_armor(/datum/armor/abductor_combat)
			icon_state = "vest_combat"
		if(VEST_COMBAT)// TO STEALTH
			mode = VEST_STEALTH
			set_armor(/datum/armor/abductor_vest)
			icon_state = "vest_stealth"
	if(ishuman(loc))
		var/mob/living/carbon/human/human_target = loc
		human_target.update_worn_oversuit()
	update_item_action_buttons()

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(datum/icon_snapshot/entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/ActivateStealth()
	if(disguise == null)
		return
	stealth_active = TRUE
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(wearer), wearer.dir)
		wearer.name_override = disguise.name
		wearer.icon = disguise.icon
		wearer.icon_state = disguise.icon_state
		wearer.cut_overlays()
		wearer.add_overlay(disguise.overlays)
		wearer.update_held_items()

/obj/item/clothing/suit/armor/abductor/vest/proc/DeactivateStealth()
	if(!stealth_active)
		return
	stealth_active = FALSE
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(wearer), wearer.dir)
		wearer.name_override = null
		wearer.cut_overlays()
		wearer.regenerate_icons()

/obj/item/clothing/suit/armor/abductor/vest/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	DeactivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/IsReflect()
	DeactivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/ui_action_click()
	switch(mode)
		if(VEST_COMBAT)
			Adrenaline()
		if(VEST_STEALTH)
			if(stealth_active)
				DeactivateStealth()
			else
				ActivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(ishuman(loc))
		if(combat_cooldown < initial(combat_cooldown))
			to_chat(loc, span_warning("Combat injection is still recharging."))
			return
		var/mob/living/carbon/human/wearer = loc
		wearer.stamina.adjust(75, forced = TRUE)
		wearer.SetUnconscious(0)
		wearer.SetStun(0)
		wearer.SetKnockdown(0)
		wearer.SetImmobilized(0)
		wearer.SetParalyzed(0)
		combat_cooldown = 0
		START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/abductor/vest/process(seconds_per_tick)
	combat_cooldown += seconds_per_tick
	if(combat_cooldown >= initial(combat_cooldown))
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/abductor/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/machinery/abductor/console/mothership_console in GLOB.machines)
		if(mothership_console.vest == src)
			mothership_console.vest = null
			break
	return ..()
