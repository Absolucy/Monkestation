GLOBAL_LIST_EMPTY(used_monthly_token)

/// Token for each player in the round, used to backup tokens to logs at roundend.
GLOBAL_LIST_EMPTY(saved_token_values)

///assoc list of how many event tokens each role gets each month
GLOBAL_LIST_INIT(patreon_etoken_values, list(
	NO_RANK = 0,
	THANKS_RANK = 100,
	ASSISTANT_RANK = 500,
	COMMAND_RANK = 1000,
	TRAITOR_RANK = 2500,
	NUKIE_RANK = 5000,
))

GLOBAL_LIST_INIT(token_tiers_to_names, list(
	TOKEN_ANTAG_HIGH = "High Threat",
	TOKEN_ANTAG_MEDIUM = "Medium Threat",
	TOKEN_ANTAG_LOW = "Low Threat",
	TOKEN_EVENT = "Event",
))

GLOBAL_LIST_INIT(token_names_to_tiers, init_token_names_to_tiers())

/client
	var/datum/meta_token_holder/client_token_holder

/datum/meta_token_holder
	///the client that owns this holder
	var/client/owner
	/// Values of all antag tokens
	var/list/tokens = list()
	///the antagonist we are currently waiting for a reply on whether we can use
	var/datum/antagonist/in_queue
	var/in_queued_tier
	///is the queued token a donor token
	var/queued_donor = FALSE
	/// Can we use a donor antag token?
	var/donor_antag_token = FALSE
	/// Can we use a donor event token?
	var/donor_event_token = FALSE
	///what token event do we currently have queued
	var/datum/twitch_event/queued_token_event
	/// The timer for the antag token timeout
	var/antag_timeout
	/// The timer for the event token timeout
	var/event_timeout
	/// If we've fetched our tokens from the database at least once already.
	var/have_fetched = FALSE
	/// If we're currently fetching our tokens from the database.
	var/currently_fetching = FALSE
	var/static/month_number = 0

/datum/meta_token_holder/New(client/creator)
	. = ..()
	if(!creator)
		return
	for(var/tier in GLOB.token_tiers_to_names)
		tokens[tier] = 0
	month_number ||= text2num(time2text(world.realtime, "MM"))
	owner = creator
	fetch()

/datum/meta_token_holder/Destroy(force)
	owner = null
	queued_token_event = null
	if(in_queue)
		QDEL_NULL(in_queue)
	if(antag_timeout)
		deltimer(antag_timeout)
		antag_timeout = null
	if(event_timeout)
		deltimer(event_timeout)
		event_timeout = null
	return ..()

/datum/meta_token_holder/proc/adjust_tokens(tier, amount = 0)
	if(QDELETED(src) || QDELETED(owner) || !IS_SAFE_NUM(amount) || amount <= 0)
		return
	tier = sanitize_token_tier(tier)
	if(!GLOB.token_tiers_to_names[tier])
		CRASH("Invalid token tier passed to adjust_token: [tier]")
	sync()
	var/list/old_tokens = tokens.Copy()
	tokens[tier] += amount
	var/datum/db_query/query_update_token = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("antag_tokens")]
			(`ckey`, `tier`, `amount`)
		VALUES
			(:ckey, :tier, :amount)
		ON DUPLICATE KEY UPDATE
			`amount` = `amount` + :amount
	"}, list("ckey" = owner.ckey, "tier" = tier, "amount" = amount))
	query_update_token.Execute()
	qdel(query_update_token)
	log_admin("[key_name(owner)] had their antag tokens adjusted from [json_encode(old_tokens)] to [json_encode(tokens)]")

/datum/meta_token_holder/proc/spend_antag_token(tier, use_donor = FALSE)
	if(use_donor && donor_antag_token)
		use_donor_for_month()
		return
	adjust_tokens(tier, -1)

/datum/meta_token_holder/proc/use_donor_for_month(event = FALSE)
	if(event)
		donor_event_token = FALSE
	else
		donor_antag_token = FALSE
	logger.Log(LOG_CATEGORY_META, "[owner], used donator [event ? "event" : "antag"] token on [month_number].")
	var/datum/db_query/query_set_donor = SSdbcore.NewQuery({"
		UPDATE [format_table_name("player")]
		SET
			`[event ? "event_token_month" : "antag_token_month"]` = :month
		WHERE
			`ckey` = :ckey
	"}, list("ckey" = owner.ckey, month = month_number))
	query_set_donor.warn_execute()
	qdel(query_set_donor)

/proc/init_token_names_to_tiers()
	. = list()
	for(var/tier in GLOB.token_tiers_to_names)
		var/name = GLOB.token_tiers_to_names[tier]
		.[name] = tier

/proc/is_token_tier_or_name(tier)
	return !isnull(GLOB.token_names_to_tiers[tier]) || !isnull(GLOB.token_tiers_to_names[tier])

/proc/sanitize_token_tier(tier)
	if(GLOB.token_names_to_tiers[tier])
		return GLOB.token_names_to_tiers[tier]
	else if(GLOB.token_tiers_to_names[tier])
		return tier
