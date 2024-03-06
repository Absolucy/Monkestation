GLOBAL_LIST_EMPTY_TYPED(parsed_audio, /datum/yt_dlp_info)

/datum/yt_dlp_info
	/// The URL to the video that this info represents.
	var/original_url
	/// The title of the video.
	var/title
	/// How long (in deciseconds) the video is.
	var/full_duration
	/// The time (in deciseconds) the video starts.
	var/start_time
	/// The time (in deciseconds) the video ends.
	var/end_time
	/// The actual URL to the video audio to be played.
	var/media_url
	/// Cached metadata for the tgui panel video player
	var/list/cached_metadata

/datum/yt_dlp_info/proc/play(list/client/users)
	if(!islist(users))
		users = list(users)
	if(!length(users) || !istext(media_url))
		return
	if(!cached_metadata)
		cached_metadata = list(
			"start" = (start_time * 0.1),
			"end" = (end_time * 0.1),
			"link" = original_url,
			"title" = title,
			"duration" = (full_duration * 0.1)
		)
	for(var/client/user as anything in users)
		if(!istype(user) || QDELING(user))
			continue
		user.tgui_panel?.play_music(media_url, cached_metadata)

/datum/yt_dlp_info/proc/duration(seconds = FALSE)
	. = full_duration
	if(isnum(start_time))
		. -= start_time
	if(seconds)
		. *= 0.1

/datum/yt_dlp_info/proc/current_progress(started_at, seconds = FALSE)
	if(!isnum(start_time) || (world.time >= started_at))
		return 0
	. = clamp(world.time - started_at, 0, full_duration)
	if(seconds)
		. *= 0.1

/proc/parse_yt_dlp(url, mob/user)
	if(!istext(url))
		return
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		return
	var/original_url = trim(url)
	if(GLOB.parsed_audio[original_url])
		return GLOB.parsed_audio[original_url]
	var/shell_safe_url = shell_url_scrub(original_url)
	var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_safe_url]\"")
	///any errors
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	///the standard output
	var/stdout = output[SHELLEO_STDOUT]
	var/list/data
	try
		data = json_decode(stdout)
	catch(var/exception/error) ///catch errors here
		if(!QDELETED(user))
			to_chat(user, "[span_boldwarning("yt-dlp JSON parsing FAILED:")]]\n[span_warning("[error]: [stdout]")]", confidential = TRUE)
		return
	if(!length(data?["url"]))
		return
	var/datum/yt_dlp_info/info = new
	info.original_url = original_url
	info.title = trim(data["title"])
	info.full_duration = CEILING(data["duration"] * 10, 1 SECONDS)
	info.start_time = isnum(data["start_time"]) ? FLOOR(data["start_time"] * 10, 1 SECONDS) : 0
	info.end_time = isnum(data["end_time"]) ? CEILING(data["end_time"] * 10, 1 SECONDS) : info.full_duration
	info.media_url = data["url"]
	return info
