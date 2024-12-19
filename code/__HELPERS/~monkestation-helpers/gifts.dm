/// Returns a list of all items in our contents that were obtained from gifts.
/atom/proc/get_all_gift_contents() as /list
	RETURN_TYPE(/list/obj/item)
	. = list()
	for(var/obj/item/thing as anything in get_all_contents_type(/obj/item))
		if(!QDELETED(thing) && HAS_TRAIT(thing, TRAIT_GIFT_ITEM))
			. += thing
