/datum/atom_hud/alternate_appearance/basic/music_cooldown
	var/image/cooldown_maptext

/datum/atom_hud/alternate_appearance/basic/music_cooldown/show_to(mob/new_viewer)
	. = ..()
	if(cooldown_maptext && !QDELETED(new_viewer) && !QDELETED(new_viewer.client))
		new_viewer.client.images |= cooldown_maptext

/datum/atom_hud/alternate_appearance/basic/music_cooldown/hide_from(mob/former_viewer, absolute)
	. = ..()
	if(cooldown_maptext && !QDELETED(former_viewer) && !QDELETED(former_viewer.client))
		former_viewer.client.images -= cooldown_maptext

/datum/atom_hud/alternate_appearance/basic/music_cooldown/proc/give_cooldowns()
	if(!cooldown_maptext)
		return
	for(var/mob/user as anything in hud_users_all_z_levels)
		if(QDELETED(user) || QDELETED(user.client))
			continue
		user.client.images |= cooldown_maptext

/datum/atom_hud/alternate_appearance/basic/music_cooldown/proc/take_cooldowns()
	if(!cooldown_maptext)
		return
	for(var/mob/user as anything in hud_users_all_z_levels)
		if(QDELETED(user) || QDELETED(user.client))
			continue
		user.client.images -= cooldown_maptext
