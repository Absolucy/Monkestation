/proc/log_and_message(msg, header = null, header_color = "purple")
	SEND_TEXT(world.log, (header ? "=== [header] ===\n[msg]" : msg))
	to_chat_immediate(world, header ? fieldset_block(html_encode(header), span_bolddanger(msg), "boxed_message [header_color]_box") : span_bolddanger(msg), type = MESSAGE_TYPE_DEBUG)

#define UPDATE_TIME (30 SECONDS)
#define EXPECTED_REF_COUNT 2

/proc/should_ignore_list(list/list)
	return FALSE

/proc/calculate_all_list_sizes()
	RETURN_TYPE(/list)
	var/total_lists = 0
	var/dangling_lists = 0
	var/min_refcount
	var/max_refcount = 0
	for(var/list/list)
		var/list_refcount = refcount(list)
		min_refcount = isnull(min_refcount) ? list_refcount : min(min_refcount, list_refcount)
		max_refcount = max(max_refcount, list_refcount)
		if(list_refcount < EXPECTED_REF_COUNT)
			dangling_lists++
		else
			total_lists++
	log_and_message("Found [total_lists] lists (+ [dangling_lists] dangling lists)\nSmallest refcount: [min_refcount]\nHighest refcount: [max_refcount]", header = "List Count")
	var/list/sizes = list()
	var/iter = 0
	var/last_update_iter = 0
	var/start_time = world.timeofday
	var/last_update = world.timeofday
	var/next_update = world.timeofday + (10 SECONDS) // first update is 10 secs
	var/update_num = 1
	var/sizes_ref = ref(sizes)
	var/total_items = 0
	for(var/list/list)
		if(refcount(list) < EXPECTED_REF_COUNT)
			CHECK_TICK_HIGH_PRIORITY
			continue
		var/list_ref = ref(list)
		if(list_ref == sizes_ref)
			log_and_message("skipping sizes list \ref[sizes]")
			CHECK_TICK_HIGH_PRIORITY
			continue
		else if(!isnull(sizes[list_ref]))
			log_and_message("iterated [list_ref] twice!!", header = "List Scanning Issue", header_color = "red")
			CHECK_TICK_HIGH_PRIORITY
			continue
		var/items = length(list)
		total_items += items
		sizes[list_ref] = items
		iter++
		var/current_time = world.timeofday
		if(current_time >= next_update)
			var/total_time_text = DisplayTimeText(round(current_time - start_time, 1 SECONDS))
			var/iter_diff = iter - last_update_iter
			var/progress = round((iter / total_lists) * 100, 0.1)
			var/progress_diff = round((iter_diff / total_lists) * 100, 0.1)
			var/lists_per_second = round((iter_diff * 10) / (current_time - last_update), 1)
			log_and_message("Checked [iter] lists (approx [progress]% done) in [total_time_text]\n[iter_diff] ([progress_diff]%) since last update\n[lists_per_second] lists/second", header = "List Scanning Progress (#[update_num++])")
			last_update = world.timeofday
			next_update = world.timeofday + UPDATE_TIME
			last_update_iter = iter
			CHECK_TICK
		else
			CHECK_TICK_HIGH_PRIORITY
	sizes -= sizes_ref
	return sizes

#undef EXPECTED_REF_COUNT
#undef UPDATE_TIME

/client/verb/list_scan()
	set name = "Scan All Lists"
	set category = "Debug"
	set waitfor = FALSE

	var/static/scan_in_progress
	if(scan_in_progress)
		to_chat(src, span_userdanger("Already scanning lists!"))
		return
	scan_in_progress = TRUE
	ASYNC
		_do_list_scan()
		scan_in_progress = FALSE

GLOBAL_VAR(biggest_list_ref)

/proc/_do_list_scan()
	CHECK_TICK
	log_and_message("Starting list scan. This is going to take an eternity.")
	rustg_time_reset("list_calc")
	var/list/list_sizes = calculate_all_list_sizes()
	var/time_ms = rustg_time_milliseconds("list_calc")
	CHECK_TICK

	log_and_message("Found a total of [length(list_sizes)] lists in [DisplayTimeText(round(time_ms * 0.01, 1 SECONDS))]")

	// sortTim(list_sizes, cmp = GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	// CHECK_TICK

	var/total_nonzero_len = 0
	var/nonzero_list_amt = 0
	for(var/list_ref in list_sizes)
		var/list_size = list_sizes[list_ref]
		if(list_size > 0)
			total_nonzero_len += list_size
			nonzero_list_amt++
		CHECK_TICK_HIGH_PRIORITY

	log_and_message("[nonzero_list_amt] lists\n[total_nonzero_len] items\nAverage [round(total_nonzero_len / nonzero_list_amt)] items per list", header = "List Scan Results", header_color = "green")


	var/sorted_lists = sort_list_sizes(list_sizes)
	var/list/top_sizes = list()
	for(var/ref in sorted_lists)
		var/size = sorted_lists[ref]
		top_sizes += "[ref]: [size]"
	GLOB.biggest_list_ref = sorted_lists[1]
	log_and_message(jointext(top_sizes, "\n"), header = "Largest Lists")

/proc/sort_list_sizes(list/lists, amt = 15)
	var/list/top_keys = list()
	var/list/top_values = list()
	for(var/i in 1 to amt)
		top_keys += null
		top_values += -INFINITY

	for(var/key in lists)
		var/num = lists[key]
		var/smallest_top = top_values[length(top_values)]
		if(num <= smallest_top)
			continue

		var/insert_at = length(top_values)
		for(var/i in 1 to length(top_values))
			if(num >= top_values[i])
				insert_at = i
				break

		for(var/i in insert_at to length(top_values) - 1)
			var/shift_pos = length(top_values) - (i - insert_at)
			top_values[shift_pos] = top_values[shift_pos - 1]
			top_keys[shift_pos] = top_keys[shift_pos - 1]
		top_values[insert_at] = num
		top_keys[insert_at] = key

	// Build return associative list
	var/list/result = list()
	for(var/i in 1 to length(top_keys))
		if(!isnull(top_keys[i]))
			result[top_keys[i]] = top_values[i]
	return result

#ifdef REFERENCE_TRACKING
/client/verb/scan_list_refs()
	set name = "Scan List Refs"
	set category = "Debug"
	set waitfor = FALSE

	var/static/current_scan
	if(!isnull(current_scan))
		to_chat(src, span_userdanger("Already scanning list refs for [current_scan]"))
		return

	var/ref_to_locate = trimtext(tgui_input_text(src, "Ref to find", "Meow", default = GLOB.biggest_list_ref, encode = FALSE))
	if(!ref_to_locate)
		return
	if(!isnull(current_scan))
		to_chat(src, span_userdanger("Already scanning list refs for [current_scan]"))
		return
	if(ref_to_locate[1] != "\[")
		ref_to_locate = "\[" + ref_to_locate
	if(ref_to_locate[length(ref_to_locate)] != "]")
		ref_to_locate += "]"

	var/thing = locate(ref_to_locate)
	if(!islist(thing))
		to_chat(src, span_userdanger("[ref_to_locate] is not a list! (it's a [type_but_also_for_lists(ref_to_locate)])"))
		return

	current_scan = ref_to_locate
	ASYNC
		var/whatever = INFINITY
		__search_references(thing, &whatever)
		current_scan = null

#endif
