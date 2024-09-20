/datum/config_entry/flag/replays_enabled

/datum/config_entry/string/replay_password
	default = "mrhouse101"

SUBSYSTEM_DEF(demo)
	name = "Replays"
	wait = 0.1 SECONDS
	flags = SS_TICKER | SS_BACKGROUND | SS_OK_TO_FAIL_INIT
	init_order = INIT_ORDER_REPLAYS
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	// loading_points = 1 SECONDS

	var/last_size = 0
	var/last_embedded_size = 0
	var/demo_started = 0

	var/ckey = "@@demoobserver"
	var/mob/dead/observer/dummy_observer

	var/list/embed_list = list()
	var/list/embedded_list = list()
	var/list/chat_list = list()

/datum/controller/subsystem/demo/proc/write_chat(target, message)
	if(!demo_started && !chat_list)
		return
	var/list/target_list
	if(target == GLOB.clients || target == world)
		target_list = list(world)
	else if(istype(target, /datum/controller/subsystem/demo) || target == dummy_observer || target == "d")
		target_list = list("d")
	else if(islist(target))
		target_list = list()
		for(var/T in target)
			if(istype(T, /datum/controller/subsystem/demo) || T == dummy_observer || T == "d")
				target_list += "d"
			else
				var/client/C = CLIENT_FROM_VAR(target)
				if(!QDELETED(C))
					target_list += C
	else
		var/client/C = CLIENT_FROM_VAR(target)
		if(!QDELETED(C))
			target_list = list(C)
	if(!length(target_list))
		return

	var/message_str = ""
	var/is_text = FALSE
	if(islist(message))
		if(message["text"])
			is_text = TRUE
			message_str = message["text"]
		else
			message_str = message["html"]
	else if(istext(message))
		message_str = message
	if(demo_started)
		for(var/I in 1 to length(target_list))
			if(!istext(target_list[I])) target_list[I] = REF(target_list[I])
		call_ext(DEMO_WRITER, "demo_chat")(target_list.Join(","), REF(message_str), "[is_text]")
	else if(chat_list)
		chat_list[++chat_list.len] = list(world.time, target_list, message_str, is_text)

/datum/controller/subsystem/demo/Initialize()
	/*if(!CONFIG_GET(flag/replays_enabled))
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED*/
	dummy_observer = new
	dummy_observer.forceMove(null)
	dummy_observer.key = dummy_observer.ckey = ckey
	dummy_observer.name = dummy_observer.real_name = "SSdemo Dummy Observer"

	var/revdata_list = list()
	if(GLOB.revdata)
		revdata_list["commit"] = "[GLOB.revdata.commit || GLOB.revdata.originmastercommit]"
		if(GLOB.revdata.originmastercommit) revdata_list["originmastercommit"] = "[GLOB.revdata.originmastercommit]"
		revdata_list["repo"] = "Monkestation/Monkestation2.0"
	var/revdata_str = json_encode(revdata_list)
	var/result = call_ext(DEMO_WRITER, "demo_start")(GLOB.demo_log, revdata_str)

	if(result == "SUCCESS")
		demo_started = TRUE
		for(var/L in embed_list)
			embed_resource(arglist(L))

		for(var/list/L in chat_list)
			call_ext(DEMO_WRITER, "demo_set_time_override")(L[1])
			var/list/target_list = L[2]
			for(var/I in 1 to length(target_list))
				if(!istext(target_list[I])) target_list[I] = REF(target_list[I])
			call_ext(DEMO_WRITER, "demo_chat")(target_list.Join(","), REF(L[3]), "[L[4]]")
		call_ext(DEMO_WRITER, "demo_set_time_override")("null")

		last_size = text2num(call_ext(DEMO_WRITER, "demo_get_size")())
		. = SS_INIT_SUCCESS
	else
		log_world("Failed to initialize demo system: [result]")
		. = SS_INIT_FAILURE

	embed_list = null
	chat_list = null

/datum/controller/subsystem/demo/Shutdown()
	call_ext(DEMO_WRITER, "demo_end")()

/datum/controller/subsystem/demo/Recover()
	last_size = SSdemo.last_size
	last_embedded_size = SSdemo.last_embedded_size
	demo_started = SSdemo.demo_started
	dummy_observer = SSdemo.dummy_observer
	embed_list = SSdemo.embed_list
	embedded_list = SSdemo.embedded_list
	chat_list = SSdemo.chat_list
	if(demo_started)
		flags |= SS_NO_INIT
	flush()

/datum/controller/subsystem/demo/fire()
	if(demo_started)
		last_size = text2num(call_ext(DEMO_WRITER, "demo_flush")())

/datum/controller/subsystem/demo/proc/flush()
	if(demo_started)
		last_size = text2num(call_ext(DEMO_WRITER, "demo_flush")())

/datum/controller/subsystem/demo/stat_entry(msg)
	msg += "ALL: [format_size(last_size)] | RSC: [format_size(last_embedded_size)]"
	return ..(msg)

/datum/controller/subsystem/demo/proc/format_size(size)
	if(size < 1000000)
		return "[round(size * 0.001, 0.01)]kB"
	return "[round(size * 0.000001, 0.01)]MB"

/datum/controller/subsystem/demo/proc/embed_resource(res, path)
	if(isnull(res))
		return
	res = fcopy_rsc(res)
	if(!demo_started)
		if(embed_list)
			embed_list += list(list(res, path))
		return res
	if(!res || embedded_list[res])
		return res
	var/do_del = FALSE
	if(!istext(path))
		path = "tmp/rsc_[ckey(REF(res))]_[rand(0, 100000)]"
		fcopy(res, path)
		do_del = TRUE
	var/size = length(file(path))
	last_embedded_size += size
	log_world("Embedding [REF(res)] [res] from [path] ([size] bytes)")
	if(call_ext(DEMO_WRITER, "demo_embed_resource")(REF(res), path) != "SUCCESS")
		log_world("Failed to copy [REF(res)] [res] from [path]!")
	embedded_list[res] = TRUE
	if(do_del)
		fdel(path)
	return res

/datum/controller/subsystem/demo/get_metrics()
	. = ..()
	.["custom"] = list(
		"last_size" = last_size,
		"last_embedded_size" = last_embedded_size,
	)
