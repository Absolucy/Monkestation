/datum/meta_token_holder/proc/fetch_tokens_from_db()
	if(QDELETED(src) || QDELETED(owner))
		return
	var/datum/db_query/query_get_tokens = SSdbcore.NewQuery({"
		SELECT
			`tier`, `amount`
		FROM [format_table_name("antag_tokens")]
			WHERE ckey = :ckey
	"}, list("ckey" = owner.ckey))
	if(!query_get_tokens.warn_execute())
		qdel(query_get_tokens)
		return
	while(query_get_tokens.NextRow())
		var/tier = query_get_tokens.item[1]
		var/amount = query_get_tokens.item[2]
		if(!GLOB.token_tiers_to_names[tier])
			stack_trace("Got invalid token tier '[tier]' from database!")
			continue
		tokens[tier] = amount
	qdel(query_get_tokens)

/datum/meta_token_holder/proc/fetch_donor_from_db()
	if(QDELETED(src) || QDELETED(owner))
		return
	var/datum/db_query/query_get_donor = SSdbcore.NewQuery({"
		SELECT
			`antag_token_month`, `event_token_month`
		FROM [format_table_name("player")]
			WHERE ckey = :ckey
	"}, list("ckey" = owner.ckey))
	if(!query_get_donor.warn_execute())
		qdel(query_get_donor)
		return
	if(query_get_donor.NextRow())
		donor_antag_token = (query_get_donor.item[1] != month_number)
		donor_event_token = (query_get_donor.item[2] != month_number)
	qdel(query_get_donor)

/datum/meta_token_holder/proc/sync(force = FALSE)
	if(have_fetched && !force)
		return
	fetch()
	var/timeout_at = world.time + (15 SECONDS)
	UNTIL(!currently_fetching || QDELETED(src) || (world.time >= timeout_at))

/datum/meta_token_holder/proc/fetch()
	set waitfor = FALSE
	if(currently_fetching || !SSdbcore.IsConnected())
		return
	currently_fetching = TRUE
	fetch_tokens_from_db()
	if(owner.patreon?.has_access(ACCESS_TRAITOR_RANK))
		fetch_donor_from_db()
	currently_fetching = FALSE
	have_fetched = TRUE
