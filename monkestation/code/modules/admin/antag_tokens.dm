/client/proc/adjust_players_antag_tokens()
	set name = "Adjust Antag/Event Tokens"
	set desc = "You can modifiy a targets antag/event token balance by adding or subtracting."
	set category = "Admin.Fun"

	if(!check_rights(R_ADMIN))
		return

	var/mob/chosen_player = tgui_input_list(src, "Choose a Player", "Player List", GLOB.player_list)
	var/client/chosen_client = chosen_player?.client
	if(QDELETED(chosen_client))
		return
	var/adjustment_amount = tgui_input_number(src, "How much should we adjust this users antag tokens by?", "Input Value", TRUE, 10, -10)
	if(!adjustment_amount || QDELETED(chosen_client))
		return
	var/tier = tgui_input_list(src, "Choose a tier for the token", "Tier List", assoc_to_keys(GLOB.token_names_to_tiers))
	if(!tier || QDELETED(chosen_client))
		return

	log_admin("[key_name(src)] adjusted the [tier] antag tokens of [key_name(chosen_client)] by [adjustment_amount].")
	chosen_client.client_token_holder.adjust_tokens(tier, adjustment_amount)
