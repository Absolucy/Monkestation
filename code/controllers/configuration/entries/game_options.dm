/datum/config_entry/number_list/repeated_mode_adjust

/datum/config_entry/keyed_list/max_pop
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/max_pop/ValidateListEntry(key_name)
	return key_name in config.modes

/datum/config_entry/keyed_list/min_pop
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/min_pop/ValidateListEntry(key_name, key_value)
	return key_name in config.modes

/datum/config_entry/number/damage_multiplier
	default = 1
	integer = FALSE

/datum/config_entry/number/minimal_access_threshold //If the number of players is larger than this threshold, minimal access will be turned on.
	min_val = 0

/datum/config_entry/flag/jobs_have_minimal_access //determines whether jobs use minimal access or expanded access.

/datum/config_entry/flag/assistants_have_maint_access

/datum/config_entry/flag/security_has_maint_access

/datum/config_entry/flag/everyone_has_maint_access

/datum/config_entry/number/depsec_access_level
	default = 1
	min_val = 0
	max_val = 2

/datum/config_entry/flag/sec_start_brig //makes sec start in brig instead of dept sec posts

/datum/config_entry/flag/force_random_names

/datum/config_entry/flag/humans_need_surnames

/datum/config_entry/flag/allow_ai // allow ai job

/datum/config_entry/flag/allow_ai_multicam // allow ai multicamera mode

/datum/config_entry/flag/disable_human_mood

/datum/config_entry/flag/disable_secborg // disallow secborg model to be chosen.

/datum/config_entry/flag/disable_peaceborg

/datum/config_entry/flag/disable_warops

/datum/config_entry/number/traitor_scaling_coeff //how much does the amount of players get divided by to determine traitors
	default = 6
	integer = FALSE
	min_val = 0

/datum/config_entry/number/brother_scaling_coeff //how many players per brother team
	default = 25
	integer = FALSE
	min_val = 0

/// Determines the ideal player count for maximum progression per minute.
/datum/config_entry/number/traitor_ideal_player_count
	default = 20
	min_val = 1

/// Determines how fast traitors scale in general.
/datum/config_entry/number/traitor_scaling_multiplier
	default = 1
	min_val = 0.01

/// Determines how many potential objectives a traitor can have.
/datum/config_entry/number/maximum_potential_objectives
	default = 6
	min_val = 1

/datum/config_entry/number/changeling_scaling_coeff //how much does the amount of players get divided by to determine changelings
	default = 6
	integer = FALSE
	min_val = 0

/datum/config_entry/number/ecult_scaling_coeff //how much does the amount of players get divided by to determine e_cult
	default = 6
	integer = FALSE
	min_val = 0

/datum/config_entry/number/security_scaling_coeff //how much does the amount of players get divided by to determine open security officer positions
	default = 8
	integer = FALSE
	min_val = 0

/datum/config_entry/number/traitor_objectives_amount
	default = 2
	min_val = 0

/datum/config_entry/number/brother_objectives_amount
	default = 2
	min_val = 0

/datum/config_entry/flag/reactionary_explosions //If we use reactionary explosions, explosions that react to walls and doors

/datum/config_entry/flag/protect_roles_from_antagonist //If security and such can be traitor/cult/other

/datum/config_entry/flag/protect_assistant_from_antagonist //If assistants can be traitor/cult/other

/datum/config_entry/flag/enforce_human_authority //If non-human species are barred from joining as a head of staff

/datum/config_entry/flag/enforce_human_authority_on_everyone //If non-human species are barred from joining as a head of staff, including jobs flagged as allowed for non-humans, ie. Quartermaster.

/datum/config_entry/flag/allow_latejoin_antagonists // If late-joining players can be traitor/changeling

/datum/config_entry/number/shuttle_refuel_delay
	default = 12000
	integer = FALSE
	min_val = 0

/datum/config_entry/keyed_list/roundstart_races //races you can play as from the get go.
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG

/datum/config_entry/keyed_list/roundstart_races/ValidateListEntry(key_name, key_value)
	if(key_name in GLOB.species_list)
		return TRUE

	log_config("ERROR: [key_name] is not a valid race ID.")
	return FALSE

/datum/config_entry/keyed_list/roundstart_no_hard_check // Species contained in this list will not cause existing characters with no-longer-roundstart species set to be resetted to the human race.
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG

/datum/config_entry/keyed_list/roundstart_no_hard_check/ValidateListEntry(key_name, key_value)
	if(key_name in GLOB.species_list)
		return TRUE

	log_config("ERROR: [key_name] is not a valid race ID.")
	return FALSE

/datum/config_entry/flag/no_summon_guns //No

/datum/config_entry/flag/no_summon_magic //Fun

/datum/config_entry/flag/no_summon_events //Allowed

/datum/config_entry/flag/no_intercept_report //Whether or not to send a communications intercept report roundstart. This may be overridden by gamemodes.

/datum/config_entry/number/arrivals_shuttle_dock_window //Time from when a player late joins on the arrivals shuttle to when the shuttle docks on the station
	default = 55
	integer = FALSE
	min_val = 30

/datum/config_entry/flag/arrivals_shuttle_require_undocked //Require the arrivals shuttle to be undocked before latejoiners can join

/datum/config_entry/flag/arrivals_shuttle_require_safe_latejoin //Require the arrivals shuttle to be operational in order for latejoiners to join

/datum/config_entry/string/alert_green
	default = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."

/datum/config_entry/string/alert_blue_upto
	default = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."

/datum/config_entry/string/alert_blue_downto
	default = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."

/datum/config_entry/string/alert_red_upto
	default = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."

/datum/config_entry/string/alert_red_downto
	default = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."

/datum/config_entry/string/alert_delta
	default = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

// monkestation start: additional alert levels
/datum/config_entry/string/alert_epsilon
	default = "Central Command has ordered the Epsilon security level on the station. Consider all contracts terminated."

/datum/config_entry/string/alert_yellow
	default = "The security alert level has been changed to yellow. There is currently a critical engineering issue on board %STATION_NAME%. Crewmembers are advised to avoid damaged areas, and report them as needed."

/datum/config_entry/string/alert_amber
	default = "The security alert level has been changed to amber. There is an ongoing C-B-R-N threat to the station. Crewmembers are advised to don protective gear, and personal oxygen systems until the alert is lifted. Report any symptoms to medical personnel immediately."

/datum/config_entry/string/alert_gamma
	default = "Central Command has issued an elevated security alert. There is an elevated threat designated by Central Command on board the station. All security forces are to stay armed and on high alert, remaining staff are advised to seek shelter in their departments."

/datum/config_entry/string/alert_lambda
	default = "Central Command has detected a large spike of dimensional energy, consistent with the summoning of \[REDACTED\] entities. You are advised to make what little time you have left worthwhile; as no additional assets will be dispatched to %STATION_NAME% at this time."
// monkestation end

/datum/config_entry/flag/revival_pod_plants

/datum/config_entry/number/revival_brain_life
	default = -1
	integer = FALSE
	min_val = -1

/datum/config_entry/flag/ooc_during_round

// deprecated for unclear name
/datum/config_entry/number/commendations
	integer = FALSE
	deprecated_by = /datum/config_entry/number/commendation_percent_poll

/datum/config_entry/number/commendation_percent_poll
	integer = FALSE

/datum/config_entry/flag/emojis

/datum/config_entry/keyed_list/multiplicative_movespeed
	key_mode = KEY_MODE_TYPE
	value_mode = VALUE_MODE_NUM
	default = list( //DEFAULTS
	/mob/living/simple_animal = 1,
	/mob/living/silicon/pai = 1,
	/mob/living/carbon/alien/adult/hunter = -1,
	/mob/living/carbon/alien/adult/royal/praetorian = 1,
	/mob/living/carbon/alien/adult/royal/queen = 3
	)

/datum/config_entry/keyed_list/multiplicative_movespeed/ValidateAndSet()
	. = ..()
	if(.)
		update_config_movespeed_type_lookup(TRUE)

/datum/config_entry/keyed_list/multiplicative_movespeed/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_config_movespeed_type_lookup(TRUE)

/datum/config_entry/number/movedelay //Used for modifying movement speed for mobs.
	abstract_type = /datum/config_entry/number/movedelay

/datum/config_entry/number/movedelay/ValidateAndSet()
	. = ..()
	if(.)
		update_mob_config_movespeeds()

/datum/config_entry/number/movedelay/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_mob_config_movespeeds()

/datum/config_entry/number/movedelay/run_delay
	integer = FALSE

/datum/config_entry/number/movedelay/run_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/run)
	M.sync()

/datum/config_entry/number/movedelay/walk_delay
	integer = FALSE

/datum/config_entry/number/movedelay/walk_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/walk)
	M.sync()

/datum/config_entry/number/movedelay/sprint_delay
	integer = FALSE

/datum/config_entry/number/movedelay/sprint_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/sprint)
	M.sync()

/////////////////////////////////////////////////Outdated move delay
/datum/config_entry/number/outdated_movedelay
	deprecated_by = /datum/config_entry/keyed_list/multiplicative_movespeed
	abstract_type = /datum/config_entry/number/outdated_movedelay
	integer = FALSE
	var/movedelay_type

/datum/config_entry/number/outdated_movedelay/DeprecationUpdate(value)
	return "[movedelay_type] [value]"

/datum/config_entry/number/outdated_movedelay/human_delay
	movedelay_type = /mob/living/carbon/human
/datum/config_entry/number/outdated_movedelay/robot_delay
	movedelay_type = /mob/living/silicon/robot
/datum/config_entry/number/outdated_movedelay/alien_delay
	movedelay_type = /mob/living/carbon/alien

/datum/config_entry/number/outdated_movedelay/animal_delay
	movedelay_type = /mob/living/simple_animal
/////////////////////////////////////////////////

/datum/config_entry/flag/roundstart_away //Will random away mission be loaded.

/datum/config_entry/number/gateway_delay //How long the gateway takes before it activates. Default is half an hour. Only matters if roundstart_away is enabled.
	default = 18000
	integer = FALSE
	min_val = 0

/datum/config_entry/number/config_gateway_chance
	integer = FALSE
	min_val = 0
	max_val = 100

/datum/config_entry/flag/ghost_interaction

/datum/config_entry/flag/near_death_experience //If carbons can hear ghosts when unconscious and very close to death

/datum/config_entry/flag/silent_ai
/datum/config_entry/flag/silent_borg

/datum/config_entry/number/default_laws //Controls what laws the AI spawns with.
	default = 0
	min_val = 0
	max_val = 4

/// Controls if Asimov Superiority appears as a perk for humans even if standard Asimov isn't the default AI lawset
/datum/config_entry/flag/silicon_asimov_superiority_override

/datum/config_entry/number/silicon_max_law_amount
	default = 12
	min_val = 0

/datum/config_entry/keyed_list/specified_laws
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG

/datum/config_entry/keyed_list/random_laws
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG

/datum/config_entry/keyed_list/law_weight
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	splitter = ","

/datum/config_entry/number/max_law_len
	default = 1024

/datum/config_entry/number/overflow_cap
	default = -1
	min_val = -1

/datum/config_entry/string/overflow_job
	default = JOB_ASSISTANT

/datum/config_entry/flag/spring_enabled

/datum/config_entry/flag/summer_enabled

/datum/config_entry/flag/spooktober_enabled

/datum/config_entry/flag/grey_assistants

/datum/config_entry/number/lavaland_budget
	default = 60
	integer = FALSE
	min_val = 0

/datum/config_entry/number/icemoon_budget
	default = 90
	integer = FALSE
	min_val = 0

/datum/config_entry/number/space_budget
	default = 16
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/allow_random_events // Enables random events mid-round when set

/datum/config_entry/flag/forbid_station_traits

/datum/config_entry/number/events_min_time_mul // Multipliers for random events minimal starting time and minimal players amounts
	default = 1
	min_val = 0
	integer = FALSE

/datum/config_entry/number/events_min_players_mul
	default = 1
	min_val = 0
	integer = FALSE

/datum/config_entry/number/mice_roundstart
	default = 10
	min_val = 0

/datum/config_entry/number/bombcap
	default = 14
	min_val = 4

/datum/config_entry/number/bombcap/ValidateAndSet(str_val)
	. = ..()
	if(.)
		GLOB.MAX_EX_DEVESTATION_RANGE = round(config_entry_value / 4)
		GLOB.MAX_EX_HEAVY_RANGE = round(config_entry_value / 2)
		GLOB.MAX_EX_LIGHT_RANGE = config_entry_value
		GLOB.MAX_EX_FLASH_RANGE = config_entry_value
		GLOB.MAX_EX_FLAME_RANGE = config_entry_value

/datum/config_entry/number/emergency_shuttle_autocall_threshold
	min_val = 0
	max_val = 1
	integer = FALSE

/datum/config_entry/flag/roundstart_traits

/datum/config_entry/flag/enable_night_shifts

/datum/config_entry/flag/randomize_shift_time

/datum/config_entry/flag/shift_time_realtime

/datum/config_entry/number/shift_time_start_hour
	default = 12
	min_val = 0
	max_val = 23

/datum/config_entry/number/monkeycap
	default = 64
	min_val = 0

/datum/config_entry/number/ratcap
	default = 64
	min_val = 0

/datum/config_entry/number/cowcap
	default = 35
	min_val = 0

/datum/config_entry/number/pigcap
	default = 35
	min_val = 0

/datum/config_entry/number/maxfine
	default = 1000
	min_val = 0

/datum/config_entry/flag/dynamic_config_enabled

/datum/config_entry/string/drone_required_role
	default = "Silicon"

/datum/config_entry/number/drone_role_playtime
	default = 14
	min_val = 0
	integer = FALSE // It is in hours, but just in case one wants to specify minutes.

/datum/config_entry/flag/native_fov

/datum/config_entry/flag/disallow_title_music

/datum/config_entry/number/station_goal_budget
	default = 1
	min_val = 0
	integer = FALSE

/datum/config_entry/flag/disallow_circuit_sounds

/datum/config_entry/flag/give_tutorials_without_db

/datum/config_entry/string/metacurrency_name
	config_entry_value = "Monkecoins"
