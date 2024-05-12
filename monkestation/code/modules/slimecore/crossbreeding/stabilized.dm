/obj/item/slimecross/stabilized/get_held_mob()
	if(isnull(loc))
		return null
	if(isliving(loc))
		return loc
	var/mob/living/holder = get(loc, /mob/living)
	if(!QDELETED(holder))
		return holder
	return null
