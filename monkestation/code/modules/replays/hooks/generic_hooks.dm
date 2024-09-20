/*
/atom
	var/image/demo_last_appearance

/atom/movable
	var/atom/demo_last_loc

/client/New()
	SSdemo.write_event_line("login [ckey]")
	. = ..()

/client/Del()
	. = ..()
	SSdemo.write_event_line("logout [ckey]")
*/
