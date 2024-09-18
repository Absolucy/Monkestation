/obj/machinery/gravity_generator/main
	/// If true, the sound loop will be disabled.
	var/shut_up = FALSE

/obj/machinery/gravity_generator/main/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name == NAMEOF(src, shut_up))
		if(var_value)
			QDEL_NULL(soundloop)
		else if(QDELETED(soundloop))
			soundloop = new(src, start_immediately = on)
