#define TMP_UPSCALE_PATH "data/tmpupscale.png"

/// Upscales an icon using rust-g.
/// You really shouldn't use this TOO often, as it has to copy the icon to a temporary png file,
/// resize it, fcopy_rsc the resized png, and then create a new /icon from said png.
/proc/resize_icon(icon/icon, width, height, resize_type = RUSTG_RESIZE_NEAREST) as /icon
	RETURN_TYPE(/icon)
	if(!istype(icon))
		CRASH("Attempted to upscale non-icon")
	if(!IS_SAFE_NUM(width) || !IS_SAFE_NUM(height))
		CRASH("Attempted to upscale icon to non-number width/height")
	if(!fcopy(icon, TMP_UPSCALE_PATH))
		CRASH("Failed to create temporary png file to upscale")
	rustg_dmi_resize_png(TMP_UPSCALE_PATH, "[width]", "[height]", resize_type)
	. = icon(fcopy_rsc(TMP_UPSCALE_PATH))
	fdel(TMP_UPSCALE_PATH)

#undef TMP_UPSCALE_PATH
