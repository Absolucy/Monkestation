/mob/dead/observer/Login()
	if(interview_safety(src, "observing"))
		qdel(client)
		return FALSE
	. = ..()
	if(!. || !client)
		return FALSE

	ghost_accs = client.prefs.read_preference(/datum/preference/choiced/ghost_accessories)
	ghost_others = client.prefs.read_preference(/datum/preference/choiced/ghost_others)
	var/preferred_form = null

	if(isAdminGhostAI(src))
		has_unlimited_silicon_privilege = TRUE

	if(client.prefs.unlock_content)
		preferred_form = client.prefs.read_preference(/datum/preference/choiced/ghost_form)
		ghost_orbit = client.prefs.read_preference(/datum/preference/choiced/ghost_orbit)

	update_icon(ALL, preferred_form)
	updateghostimages()
	lighting_cutoff = default_lighting_cutoff()
	update_sight()


