/obj/item/botanical_lexicon
	name = "Botanical Lexicon"
	desc = "A transcribed list of all known plant mutations and how to aquire them"
	icon = 'monkestation/icons/obj/ranching.dmi'
	icon_state = "chicken_book"

/obj/item/botanical_lexicon/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotanicalLexicon")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/botanical_lexicon/ui_act(action, list/params)
	if(..())
		return

/obj/item/botanical_lexicon/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/seeds/botanical_lexicon)
	)

/obj/item/botanical_lexicon/ui_static_data(mob/user)
	var/list/data = list()
	var/list/plant_list = list()
	for(var/datum/hydroponics/plant_mutation/mutation as anything in (subtypesof(/datum/hydroponics/plant_mutation) - /datum/hydroponics/plant_mutation/spliced_mutation - /datum/hydroponics/plant_mutation/infusion))
		var/datum/hydroponics/plant_mutation/listed_mutation = new mutation
		var/list/details = list()
		if(!listed_mutation.created_seed)
			continue

		var/obj/item/seeds/created_seed = new listed_mutation.created_seed

		details["name"] = created_seed.name
		details["desc"] = created_seed.desc

		if(length(listed_mutation.required_potency))
			details["potency_low"] = listed_mutation.required_potency[1]
			details["potency_high"] = listed_mutation.required_potency[2]
		if(length(listed_mutation.required_yield))
			details["yield_low"] = listed_mutation.required_yield[1]
			details["yield_high"] = listed_mutation.required_yield[2]
		if(length(listed_mutation.required_production))
			details["production_low"] = listed_mutation.required_production[1]
			details["production_high"] = listed_mutation.required_production[2]
		if(length(listed_mutation.required_endurance))
			details["endurance_low"] = listed_mutation.required_endurance[1]
			details["endurance_high"] = listed_mutation.required_endurance[2]
		if(length(listed_mutation.required_lifespan))
			details["lifespan_low"] = listed_mutation.required_lifespan[1]
			details["lifespan_high"] = listed_mutation.required_lifespan[2]

		if(length(listed_mutation.mutates_from))
			var/list/parents = list()
			for(var/obj/item/seeds/linked_seed as anything in listed_mutation.mutates_from)
				parents += linked_seed::name
			details["mutates_from"] = english_list(parents)

		if(istype(listed_mutation, /datum/hydroponics/plant_mutation/infusion))
			var/datum/hydroponics/plant_mutation/infusion/infused_type = listed_mutation
			var/list/reagent_names = list()
			for(var/datum/reagent/listed_reagent as anything in infused_type.reagent_requirement)
				reagent_names += listed_reagent::name
			details["required_reagents"] = english_list(reagent_names)

		details["plant_icon"] = sanitize_css_class_name("[created_seed.icon][created_seed.icon_state]")

		QDEL_NULL(created_seed)
		plant_list += list(details)
		QDEL_NULL(listed_mutation)

	data["plant_list"] = plant_list

	return data
