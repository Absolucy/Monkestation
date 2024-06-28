/datum/species/oozeling/slime
	name = "\improper Slimeperson"
	plural_form = "Slimepeople"
	var/datum/action/innate/split_body/slime_split
	var/datum/action/innate/swap_body/swap_body

/datum/species/oozeling/slime/on_species_gain(mob/living/carbon/sloime, datum/species/old_species)
	. = ..()
	if(QDELETED(slime_split))
		slime_split = new
	if(QDELETED(swap_body))
		swap_body = new
	slime_split.Grant(sloime)
	swap_body.Grant(sloime)
	LAZYADD(sloime.mind?.slime_bodies, sloime)

/datum/species/oozeling/slime/on_species_loss(mob/living/carbon/sloime)
	. = ..()
	LAZYREMOVE(sloime.mind?.slime_bodies, sloime)
	slime_split?.Remove(sloime)
	swap_body?.Remove(sloime)
