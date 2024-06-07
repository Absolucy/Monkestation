/datum/antagonist/florida_man
	name = "Space Florida Man"
	roundend_category = "Florida Men"
	antagpanel_category = "Florida Man"
	job_rank = ROLE_FLORIDA_MAN
	objectives = list()
	show_to_ghosts = TRUE
	preview_outfit = /datum/outfit/florida_man_one
	var/datum/action/cooldown/spell/florida_doorbuster/doorbuster
	var/datum/action/cooldown/spell/florida_cuff_break/cuffbreak
	var/datum/action/cooldown/spell/florida_regeneration/regen
	/// A list of traits granted to florida man
	var/static/list/florida_traits = list(
		TRAIT_ANALGESIA,
		TRAIT_BATON_RESISTANCE,
		TRAIT_CLUMSY,
		TRAIT_DUMB,
		TRAIT_FEARLESS,
		TRAIT_HARDLY_WOUNDED,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_JAILBIRD,
		TRAIT_NOSOFTCRIT,
		TRAIT_NO_ZOMBIFY, // we do NOT need a florida zombie, that would be busted af
		TRAIT_RADIMMUNE, // rad storms can't make things worse than countless generations of inbreeding
		TRAIT_STABLEHEART,
		TRAIT_STABLELIVER,
		TRAIT_TOXIMMUNE,
		TRAIT_VENTCRAWLER_NUDE
	)

/datum/antagonist/florida_man/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/florida_man/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/carbon/human/floridan = mob_override || owner.current
	if(istype(floridan) && !QDELING(floridan))
		floridan.physiology?.bleed_mod *= 0.25
		floridan.physiology?.stun_mod *= 0.25
		floridan.physiology?.pressure_mod *= 0.25 // florida man is resistant to pressure, he doesn't even know what a "nitrogen" is
		floridan.physiology?.heat_mod *= 0.1 // floridans are used to high temperatures
		give_spells(floridan)
		floridan.add_traits(florida_traits, FLORIDA_MAN_TRAIT)
		floridan.AddElement(/datum/element/florida_strength)

/datum/antagonist/florida_man/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/carbon/human/floridan = mob_override || owner.current
	if(istype(floridan) && !QDELING(floridan))
		floridan.physiology?.bleed_mod /= 0.25
		floridan.physiology?.stun_mod /= 0.25
		floridan.physiology?.pressure_mod /= 0.25
		floridan.physiology?.heat_mod /= 0.1
		take_spells(floridan)
		REMOVE_TRAITS_IN(floridan, FLORIDA_MAN_TRAIT)
		floridan.RemoveElement(/datum/element/florida_strength)

/datum/antagonist/florida_man/proc/give_spells(mob/living/target)
	if(QDELETED(doorbuster))
		doorbuster = new
	doorbuster.Grant(target)
	if(QDELETED(cuffbreak))
		cuffbreak = new
	cuffbreak.Grant(target)
	if(QDELETED(regen))
		regen = new
	regen.Grant(target)

/datum/antagonist/florida_man/proc/take_spells(mob/living/target)
	doorbuster?.Remove(target)
	cuffbreak?.Remove(target)
	regen?.Remove(target)

/datum/antagonist/florida_man/forge_objectives()
	var/datum/objective/meth = new /datum/objective
	var/list/selected_objective = pick(GLOB.florida_man_base_objectives)

	meth.owner = owner
	meth.completed = TRUE
	if(prob(25))
		meth.explanation_text = "[selected_objective[1]] [pick(GLOB.florida_man_objective_nouns)] [selected_objective[2]], [pick(GLOB.florida_man_objective_suffix)]"
	else
		meth.explanation_text = "[selected_objective[1]] [pick(GLOB.florida_man_objective_nouns)] [selected_objective[2]]."
	objectives += meth

/datum/antagonist/florida_man/greet()
	var/mob/living/carbon/floridan = owner.current

	owner.current.playsound_local(get_turf(owner.current), 'monkestation/sound/ambience/antag/floridaman.ogg', vol = 100, vary = FALSE, use_reverb = FALSE)
	to_chat(owner, span_boldannounce("You are THE Florida Man!\nYou're not quite sure how you got out here in space, but you don't generally bother thinking about things.\n\nYou love methamphetamine!\nYou love wrestling lizards!\nYou love getting drunk!\nYou love sticking it to THE MAN!\nYou don't act with any coherent plan or objective.\nYou don't outright want to destroy the station or murder people, as you have no home to return to.\n\nGo forth, son of Space Florida, and sow chaos!"))
	owner.announce_objectives()
	if(!prob(1)) // 1% chance to be Tony Brony...because meme references to streams are good!
		floridan.fully_replace_character_name(newname = "Florida Man")
	else
		floridan.fully_replace_character_name(newname = "Tony Brony")

/datum/antagonist/florida_man/antag_token(datum/mind/hosts_mind, mob/spender)
	. = ..()
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/florida_man_three)
		new_mob.mind.add_antag_datum(/datum/antagonist/florida_man)
	else
		hosts_mind.add_antag_datum(/datum/antagonist/florida_man)
