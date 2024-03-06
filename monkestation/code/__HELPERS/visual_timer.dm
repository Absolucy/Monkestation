GLOBAL_LIST_INIT_TYPED(visual_timer_icons, 	  /list/image,	init_visual_timers())
GLOBAL_LIST_INIT_TYPED(visual_timer_tbd_icon, /image,		init_visual_tbd_icon())

#define visual_timer(fraction)						(isnull(fraction) ? GLOB.visual_timer_tbd_icon : GLOB.visual_timer_icons[fraction])
#define visual_timer_from_length(current, length)	visual_timer(get_visual_timer_fraction(current, length))

/proc/get_visual_timer_fraction(current, length)
	if(!IS_SAFE_NUM(length) || !IS_SAFE_NUM(current) || current > length)
		return null
	var/time_left = length - current
	var/fraction = 10 - clamp(round((time_left / length) * 10), 1, 9)
	return fraction

/proc/init_visual_timers()
	RETURN_TYPE(/list/image)
	. = list()
	for(var/fraction in 1 to 9)
		var/image/thingy = image(icon = 'monkestation/icons/hud/cooldown.dmi', icon_state = "second.[fraction]")
		thingy.alpha = 180
		thingy.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		. += thingy

/proc/init_visual_tbd_icon()
	RETURN_TYPE(/image)
	var/image/thingy = image(icon = 'monkestation/icons/hud/cooldown.dmi', icon_state = "second")
	thingy.alpha = 180
	thingy.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	return thingy
