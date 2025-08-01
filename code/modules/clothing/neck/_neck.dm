/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	strip_delay = 40
	equip_delay_other = 40
	blood_overlay_type = "mask"

/obj/item/clothing/neck/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(body_parts_covered & HEAD)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask")

/obj/item/clothing/neck/appears_bloody()
	return ..() && (body_parts_covered & HEAD)

/obj/item/clothing/neck/bowtie
	name = "bow tie"
	desc = "A small neosilk bowtie."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bowtie_greyscale"
	inhand_icon_state = "" //no inhands
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_CREW
	greyscale_config = /datum/greyscale_config/ties
	greyscale_config_worn = /datum/greyscale_config/ties/worn
	greyscale_colors = "#151516ff"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/bowtie/rainbow
	name = "rainbow bow tie"
	desc = "An extremely large neosilk rainbow-colored bowtie."
	icon_state = "bowtie_rainbow"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/tie
	name = "slick tie"
	desc = "A neosilk tie."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "tie_greyscale_tied"
	inhand_icon_state = "" //no inhands
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_CREW
	greyscale_config = /datum/greyscale_config/ties
	greyscale_config_worn = /datum/greyscale_config/ties/worn
	greyscale_colors = "#4d4e4e"
	flags_1 = IS_PLAYER_COLORABLE_1
	/// All ties start untied unless otherwise specified
	var/is_tied = FALSE
	/// How long it takes to tie the tie
	var/tie_timer = 4 SECONDS
	/// Is this tie a clip-on, meaning it does not have an untied state?
	var/clip_on = FALSE
	/// MONKESTATION EDIT Base icon_state name between tied and untied versions.
	var/tie_type = "tie_greyscale"

/obj/item/clothing/neck/tie/Initialize(mapload)
	. = ..()
	if(clip_on)
		return
	update_appearance(UPDATE_ICON)
	// register_context() monkestation: register_context() is already called in ..()

/obj/item/clothing/neck/tie/examine(mob/user)
	. = ..()
	if(clip_on)
		. += span_notice("Looking closely, you can see that it's actually a cleverly disguised clip-on.")
	else if(!is_tied)
		. += span_notice("The tie can be tied with Alt-Click.")
	else
		. += span_notice("The tie can be untied with Alt-Click.")

/obj/item/clothing/neck/tie/AltClick(mob/user)
	. = ..()
	if(clip_on)
		return
	to_chat(user, span_notice("You concentrate as you begin [is_tied ? "untying" : "tying"] [src]..."))
	var/tie_timer_actual = tie_timer
	// Mirrors give you a boost to your tying speed. I realize this stacks and I think that's hilarious.
	for(var/obj/structure/mirror/reflection in view(2, user))
		tie_timer_actual /= 1.25
	// Heads of staff are experts at tying their ties.
	if(user.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
		tie_timer_actual /= 2
	// Tie/Untie our tie
	if(!do_after(user, tie_timer_actual))
		to_chat(user, span_notice("Your fingers fumble away from [src] as your concentration breaks."))
		return
	// Clumsy & Dumb people have trouble tying their ties.
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		to_chat(user, span_notice("You just can't seem to get a proper grip on [src]!"))
		return
	// Success!
	is_tied = !is_tied
	user.visible_message(
		span_notice("[user] adjusts [user.p_their()] tie[HAS_TRAIT(user, TRAIT_BALD) ? "" : " and runs a hand across [user.p_their()] head"]."),
		span_notice("You successfully [is_tied ? "tied" : "untied"] [src]!"),
	)
	update_appearance(UPDATE_ICON)
	user.update_clothing(ITEM_SLOT_NECK)

/obj/item/clothing/neck/tie/update_icon()
	. = ..()
	if(clip_on)
		return
	// Normal strip & equip delay, along with 2 second self equip since you need to squeeze your head through the hole.
	if(is_tied)
		icon_state = "[tie_type]_tied" //MONKESTATION EDIT
		strip_delay = 4 SECONDS
		equip_delay_other = 4 SECONDS
		equip_delay_self = 2 SECONDS
	else // Extremely quick strip delay, it's practically a ribbon draped around your neck
		icon_state = "[tie_type]_untied" //MONKESTATION EDIT
		strip_delay = 1 SECONDS
		equip_delay_other = 1 SECONDS
		equip_delay_self = 0

/obj/item/clothing/neck/tie/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(clip_on)
		return
	if(is_tied)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Untie"
	else
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Tie"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/neck/tie/blue
	name = "blue tie"
	icon_state = "tie_greyscale_untied"
	greyscale_colors = "#5275b6ff"

/obj/item/clothing/neck/tie/red
	name = "red tie"
	icon_state = "tie_greyscale_untied"
	greyscale_colors = "#c23838ff"

/obj/item/clothing/neck/tie/red/tied
	is_tied = TRUE

/obj/item/clothing/neck/tie/red/hitman
	desc = "This is a $47,000 custom-tailored Référence Du Tueur À Gages tie. The clot is from neosilkworms raised at a tie microfarm in Cookwell, from a secret pattern passed down by monk tailors since the twenty-first century!"
	icon_state = "tie_greyscale_untied"
	tie_timer = 1 SECONDS // You're a professional.

/obj/item/clothing/neck/tie/red/hitman/tied
	is_tied = TRUE

/obj/item/clothing/neck/tie/black
	name = "black tie"
	icon_state = "tie_greyscale_untied"
	greyscale_colors = "#151516ff"

/obj/item/clothing/neck/tie/black/tied
	is_tied = TRUE

/obj/item/clothing/neck/tie/horrible
	name = "horrible tie"
	desc = "A neosilk tie. This one is disgusting."
	icon_state = "horribletie"
	clip_on = TRUE
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/disco
	name = "horrific necktie"
	icon_state = "eldritch_tie"
	desc = "The necktie is adorned with a garish pattern. It's disturbingly vivid. Somehow you feel as if it would be wrong to ever take it off. It's your friend now. You will betray it if you change it for some boring scarf."
	clip_on = TRUE
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/detective
	name = "loose tie"
	desc = "A loosely tied necktie, a perfect accessory for the over-worked detective."
	icon_state = "detective"
	clip_on = TRUE
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/maid
	name = "maid neck cover"
	desc = "A neckpiece for a maid costume, it smells faintly of disappointment."
	icon_state = "maid_neck"

/obj/item/clothing/neck/kris
	name = "vessel's ascot"
	desc = "* A replica of the ascot a vessel wore while saving the world."
	icon_state = "kris_ascot"

/obj/item/clothing/neck/ralsei
	name = "prince's scarf"
	desc = "A fluffy scarf, it smells of cake."
	icon_state = "ralsei_scarf"

/obj/item/clothing/neck/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"

/obj/item/clothing/neck/stethoscope/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] puts \the [src] to [user.p_their()] chest! It looks like [user.p_they()] won't hear much!"))
	return OXYLOSS

/obj/item/clothing/neck/stethoscope/attack(mob/living/M, mob/living/user)
	if(!ishuman(M) || !isliving(user))
		return ..()
	if((user.istate & ISTATE_HARM))
		return

	var/mob/living/carbon/carbon_patient = M
	var/body_part = parse_zone(user.zone_selected)
	var/oxy_loss = carbon_patient.getOxyLoss()

	var/heart_strength
	var/pulse_pressure

	var/obj/item/organ/internal/heart/heart = carbon_patient.get_organ_slot(ORGAN_SLOT_HEART)
	var/obj/item/organ/internal/lungs/lungs = carbon_patient.get_organ_slot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/internal/liver/liver = carbon_patient.get_organ_slot(ORGAN_SLOT_LIVER)
	var/obj/item/organ/internal/appendix/appendix = carbon_patient.get_organ_slot(ORGAN_SLOT_APPENDIX)

	var/render_list = list()//information will be packaged in a list for clean display to the user

	//determine what specific action we're taking
	switch (body_part)
		if(BODY_ZONE_CHEST)//Listening to the chest
			user.visible_message(span_notice("[user] places [src] against [carbon_patient]'s [body_part] and listens attentively."), ignored_mobs = user)
			if(!user.can_hear())
				to_chat(user, span_notice("You place [src] against [carbon_patient]'s [body_part]. Fat load of good it does you though, since you can't hear"))
				return
			else
				render_list += span_info("You place [src] against [carbon_patient]'s [body_part]:\n")

			//assess breathing
			if(!lungs)//sanity check, enusure patient actually has lungs
				render_list += "<span class='danger ml-1'>[M] doesn't have any lungs!</span>\n"
			else
				if(carbon_patient.stat == DEAD || (HAS_TRAIT(carbon_patient, TRAIT_FAKEDEATH)) || (HAS_TRAIT(carbon_patient, TRAIT_NOBREATH))|| carbon_patient.failed_last_breath || carbon_patient.losebreath)//If pt is dead or otherwise not breathing
					render_list += "<span class='danger ml-1'>[M.p_theyre(TRUE)] not breathing!</span>\n"
				else if(lungs.damage > 10)//if breathing, check for lung damage
					render_list += "<span class='danger ml-1'>You hear fluid in [M.p_their()] lungs!</span>\n"
				else if(oxy_loss > 10)//if they have suffocation damage
					render_list += "<span class='danger ml-1'>[M.p_theyre(TRUE)] breathing heavily!</span>\n"
				else
					render_list += "<span class='notice ml-1'>[M.p_theyre(TRUE)] breathing normally.</span>\n"//they're okay :D

			//assess heart
			if(body_part == BODY_ZONE_CHEST)//if we're listening to the chest
				if(!heart)//sanity check, ensure the patient actually has a heart
					render_list += "<span class='danger ml-1'>[M] doesn't have a heart!</span>\n"
				else
					if(!heart.beating || carbon_patient.stat == DEAD)
						render_list += "<span class='danger ml-1'>You don't hear a heartbeat!</span>\n"//they're dead or their heart isn't beating
					else if(heart.damage > 10 || carbon_patient.blood_volume <= BLOOD_VOLUME_OKAY)
						render_list += "<span class='danger ml-1'>You hear a weak heartbeat.</span>\n"//their heart is damaged, or they have critical blood
					else
						render_list += "<span class='notice ml-1'>You hear a healthy heartbeat.</span>\n"//they're okay :D

		if(BODY_ZONE_PRECISE_GROIN)//If we're targeting the groin
			render_list += span_info("You carefully press down on [carbon_patient]'s abdomen:\n")
			user.visible_message(span_notice("[user] presses their hands against [carbon_patient]'s abdomen."), ignored_mobs = user)

			//assess abdominal organs
			if(body_part == BODY_ZONE_PRECISE_GROIN)
				var/appendix_okay = TRUE
				var/liver_okay = TRUE
				if(!liver)//sanity check, ensure the patient actually has a liver
					render_list += "<span class='danger ml-1'>[M] doesn't have a liver!</span>\n"
					liver_okay = FALSE
				else
					if(liver.damage > 10)
						render_list += "<span class='danger ml-1'>[M.p_their(TRUE)] liver feels firm.</span>\n"//their liver is damaged
						liver_okay = FALSE

				if(!appendix)//sanity check, ensure the patient actually has an appendix
					render_list += "<span class='danger ml-1'>[M] doesn't have an appendix!</span>\n"
					appendix_okay = FALSE
				else
					if(appendix.damage > 10 && carbon_patient.stat == CONSCIOUS)
						render_list += "<span class='danger ml-1'>[M] screams when you lift your hand from [M.p_their()] appendix!</span>\n"//scream if their appendix is damaged and they're awake
						M.emote("scream")
						appendix_okay = FALSE

				if(liver_okay && appendix_okay)//if they have all their organs and have no detectable damage
					render_list += "<span class='notice ml-1'>You don't find anything abnormal.</span>\n"//they're okay :D

		if(BODY_ZONE_PRECISE_EYES)
			balloon_alert(user, "can't do that!")
			return

		if(BODY_ZONE_PRECISE_MOUTH)
			balloon_alert(user, "can't do that!")
			return

		else//targeting an extremity or the head
			if(body_part ==  BODY_ZONE_HEAD)
				render_list += span_info("You carefully press your fingers to [carbon_patient]'s neck:\n")
				user.visible_message(span_notice("[user] presses their fingers against [carbon_patient]'s neck."), ignored_mobs = user)
			else
				render_list += span_info("You carefully press your fingers to [carbon_patient]'s [body_part]:\n")
				user.visible_message(span_notice("[user] presses their fingers against [carbon_patient]'s [body_part]."), ignored_mobs = user)

			//assess pulse (heart & blood level)
			if(!heart)//sanity check, ensure the patient actually has a heart
				render_list += "<span class='danger ml-1'>[M] doesn't have a heart!</span>\n"
			else
				if(!heart.beating || carbon_patient.blood_volume <= BLOOD_VOLUME_OKAY || carbon_patient.stat == DEAD)
					render_list += "<span class='danger ml-1'>You can't find a pulse!</span>\n"//they're dead, their heart isn't beating, or they have critical blood
				else
					if(heart.damage > 10)
						heart_strength = span_danger("irregular")//their heart is damaged
					else
						heart_strength = span_notice("regular")//they're okay :D

					if(carbon_patient.blood_volume <= BLOOD_VOLUME_SAFE && carbon_patient.blood_volume > BLOOD_VOLUME_OKAY)
						pulse_pressure = span_danger("thready")//low blood
					else
						pulse_pressure = span_notice("strong")//they're okay :D

					render_list += "<span class='notice ml-1'>[M.p_their(TRUE)] pulse is [pulse_pressure] and [heart_strength].</span>\n"

	//display our packaged information in an examine block for easy reading
	to_chat(user, boxed_message(jointext(render_list, "")), type = MESSAGE_TYPE_INFO)

///////////
//SCARVES//
///////////

/obj/item/clothing/neck/scarf
	name = "scarf"
	icon_state = "scarf"
	icon_preview = 'icons/obj/previews.dmi'
	icon_state_preview = "scarf_cloth"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#EEEEEE#EEEEEE"
	greyscale_config = /datum/greyscale_config/scarf
	greyscale_config_worn = /datum/greyscale_config/scarf_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/scarf/black
	name = "black scarf"
	greyscale_colors = "#4A4A4B#4A4A4B"

/obj/item/clothing/neck/scarf/pink
	name = "pink scarf"
	greyscale_colors = "#F699CD#F699CD"

/obj/item/clothing/neck/scarf/red
	name = "red scarf"
	greyscale_colors = "#D91414#D91414"

/obj/item/clothing/neck/scarf/green
	name = "green scarf"
	greyscale_colors = "#5C9E54#5C9E54"

/obj/item/clothing/neck/scarf/darkblue
	name = "dark blue scarf"
	greyscale_colors = "#1E85BC#1E85BC"

/obj/item/clothing/neck/scarf/purple
	name = "purple scarf"
	greyscale_colors = "#9557C5#9557C5"

/obj/item/clothing/neck/scarf/yellow
	name = "yellow scarf"
	greyscale_colors = "#E0C14F#E0C14F"

/obj/item/clothing/neck/scarf/orange
	name = "orange scarf"
	greyscale_colors = "#C67A4B#C67A4B"

/obj/item/clothing/neck/scarf/cyan
	name = "cyan scarf"
	greyscale_colors = "#54A3CE#54A3CE"

/obj/item/clothing/neck/scarf/zebra
	name = "zebra scarf"
	greyscale_colors = "#333333#EEEEEE"

/obj/item/clothing/neck/scarf/christmas
	name = "christmas scarf"
	greyscale_colors = "#038000#960000"

/obj/item/clothing/neck/large_scarf
	name = "large scarf"
	icon_state = "large_scarf"
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#C6C6C6#EEEEEE"
	greyscale_config = /datum/greyscale_config/large_scarf
	greyscale_config_worn = /datum/greyscale_config/large_scarf_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/large_scarf/red
	name = "large red scarf"
	greyscale_colors = "#8A2908#A06D66"

/obj/item/clothing/neck/large_scarf/green
	name = "large green scarf"
	greyscale_colors = "#525629#888674"

/obj/item/clothing/neck/large_scarf/blue
	name = "large blue scarf"
	greyscale_colors = "#20396C#6F7F91"

/obj/item/clothing/neck/large_scarf/syndie
	name = "suspicious looking striped scarf"
	desc = "Ready to operate."
	greyscale_colors = "#B40000#545350"
	armor_type = /datum/armor/large_scarf_syndie

/obj/item/clothing/neck/infinity_scarf
	name = "infinity scarf"
	icon_state = "infinity_scarf"
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#EEEEEE"
	greyscale_config = /datum/greyscale_config/infinity_scarf
	greyscale_config_worn = /datum/greyscale_config/infinity_scarf_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/petcollar
	name = "pet collar"
	desc = "It's for pets."
	icon_state = "petcollar"
	var/tagname = null

/datum/armor/large_scarf_syndie
	fire = 50
	acid = 40

/obj/item/clothing/neck/petcollar/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	if(!ismonkey(M))
		return FALSE
	return ..()

/obj/item/clothing/neck/petcollar/attack_self(mob/user)
	tagname = sanitize_name(tgui_input_text(user, "Would you like to change the name on the tag?", "Pet Naming", "Spot", MAX_NAME_LEN))
	name = "[initial(name)] - [tagname]"

//////////////
//DOPE BLING//
//////////////

/obj/item/clothing/neck/necklace/dope
	name = "gold necklace"
	desc = "Damn, it feels good to be a gangster."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bling"

/obj/item/clothing/neck/necklace/dope/merchant
	desc = "Don't ask how it works, the proof is in the holochips!"
	/// scales the amount received in case an admin wants to emulate taxes/fees.
	var/profit_scaling = 1
	/// toggles between sell (TRUE) and get price post-fees (FALSE)
	var/selling = FALSE

/obj/item/clothing/neck/necklace/dope/merchant/attack_self(mob/user)
	. = ..()
	selling = !selling
	to_chat(user, span_notice("[src] has been set to [selling ? "'Sell'" : "'Get Price'"] mode."))

/obj/item/clothing/neck/necklace/dope/merchant/afterattack(obj/item/I, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/datum/export_report/ex = export_item_and_contents(I, delete_unsold = selling, dry_run = !selling)
	var/price = 0
	for(var/x in ex.total_amount)
		price += ex.total_value[x]

	if(price)
		var/true_price = round(price*profit_scaling)
		to_chat(user, span_notice("[selling ? "Sold" : "Getting the price of"] [I], value: <b>[true_price]</b> credits[I.contents.len ? " (exportable contents included)" : ""].[profit_scaling < 1 && selling ? "<b>[round(price-true_price)]</b> credit\s taken as processing fee\s." : ""]"))
		if(selling)
			new /obj/item/holochip(get_turf(user),true_price)
	else
		to_chat(user, span_warning("There is no export value for [I] or any items within it."))

	return .

/obj/item/clothing/neck/beads
	name = "plastic bead necklace"
	desc = "A cheap, plastic bead necklace. Show team spirit! Collect them! Throw them away! The posibilites are endless!"
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "beads"
	color = "#ffffff"
	custom_price = PAYCHECK_CREW * 0.2
	custom_materials = (list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT*5))

/obj/item/clothing/neck/beads/Initialize(mapload)
	. = ..()
	color = color = pick("#ff0077","#d400ff","#2600ff","#00ccff","#00ff2a","#e5ff00","#ffae00","#ff0000", "#ffffff")

/obj/item/clothing/neck/shawl
	name = "silk shawl"
	desc = "A delicate silk scarf with tiny sparkling fragments woven into the fabric."
	icon_state = "starshawl"
	icon = 'icons/obj/clothing/neck.dmi'
