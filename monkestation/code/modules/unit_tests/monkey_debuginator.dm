// here be dragons

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/mob/living/carbon/human
	var/_new_info
	var/_destroy_info

/mob/living/carbon/human/New()
	try
		CRASH("stupid monkey call stack hack")
	catch(var/exception/err)
		_new_info = call_stack_from_exception(err)
	return ..()

/mob/living/carbon/human/Destroy()
	try
		CRASH("stupid monkey call stack hack")
	catch(var/exception/err)
		_destroy_info = call_stack_from_exception(err)
	return ..()

/mob/living/carbon/human/dump_harddel_info()
	if(harddel_deets_dumped || !(_new_info || _destroy_info))
		return
	harddel_deets_dumped = TRUE
	var/list/info = list()
	if(_new_info)
		info += "New() call stack: \n\t[replacetext_char(_new_info, "\n", "\n\t")]"
	if(_destroy_info)
		info += "Destroy() call stack: \n\t[replacetext_char(_destroy_info, "\n", "\n\t")]"
	return jointext(info, "\n-----\n")

// ---

/obj/item/organ/internal
	var/_new_info
	var/_destroy_info
	var/_insert_info

/obj/item/organ/internal/New()
	try
		CRASH("stupid monkey call stack hack")
	catch(var/exception/err)
		_new_info = call_stack_from_exception(err)
	return ..()

/obj/item/organ/internal/Destroy()
	try
		CRASH("stupid monkey call stack hack")
	catch(var/exception/err)
		_destroy_info = call_stack_from_exception(err)
	return ..()

/obj/item/organ/internal/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	try
		CRASH("stupid monkey call stack hack")
	catch(var/exception/err)
		_insert_info = call_stack_from_exception(err)
	return ..()

/obj/item/organ/internal/dump_harddel_info()
	if(harddel_deets_dumped || !(_new_info || _destroy_info || _insert_info))
		return
	harddel_deets_dumped = TRUE
	var/list/info = list()
	if(_new_info)
		info += "New() call stack: \n\t[replacetext_char(_new_info, "\n", "\n\t")]"
	if(_destroy_info)
		info += "Destroy() call stack: \n\t[replacetext_char(_destroy_info, "\n", "\n\t")]"
	if(_insert_info)
		info += "Insert() call stack: \n\t[replacetext_char(_insert_info, "\n", "\n\t")]"
	return jointext(info, "\n-----\n")

/proc/call_stack_from_exception(exception/err)
	var/desc = "[err.desc]"
	var/start_pos = findtext_char(desc, "call stack:")
	if(start_pos)
		return trimtext(copytext_char(desc, start_pos + 11))
#endif
