/**
 * # Techweb Node
 *
 * A datum representing a researchable node in the techweb.
 *
 * Techweb nodes are GLOBAL, there should only be one instance of them in the game. Persistant
 * changes should never be made to them in-game. USE SSRESEARCH PROCS TO OBTAIN REFERENCES.
 * DO NOT REFERENCE OUTSIDE OF SSRESEARCH OR YOU WILL FUCK UP GC.
 */
/datum/techweb_node
	/// Internal ID of the node
	var/id
	/// The name of the node as it is shown on UIs
	var/display_name = "Errored Node"
	/// A description of the node to show on UIs
	var/description = "Why are you seeing this?"
	/// Whether it starts off hidden
	var/hidden = FALSE
	/// If the tech can be randomly generated by BEPIS tech as a reward. Meant to be fully given in tech disks, not researched
	var/experimental = FALSE
	/// Whether it's available without any research
	var/starting_node = FALSE
	var/list/prereq_ids = list()
	var/list/design_ids = list()
	/// CALCULATED FROM OTHER NODE'S PREREQUISITIES. Associated list id = TRUE
	var/list/unlock_ids = list()
	/// List of items you need to deconstruct to unlock this node.
	var/list/required_items_to_unlock = list()
	/// Boosting this will autounlock this node
	var/autounlock_by_boost = TRUE
	/// The points cost to research the node, type = amount
	var/list/research_costs = list()
	/// The category of the node
	var/category = "Misc"
	/// The list of experiments required to research the node
	var/list/required_experiments = list()
	/// If completed, these experiments give a specific point amount discount to the node.area
	var/list/discount_experiments = list()
	/// Whether or not this node should show on the wiki
	var/show_on_wiki = TRUE

/datum/techweb_node/error_node
	id = "ERROR"
	display_name = "ERROR"
	description = "This usually means something in the database has corrupted. If it doesn't go away automatically, inform Central Command for their techs to fix it ASAP(tm)"
	show_on_wiki = FALSE

/datum/techweb_node/proc/Initialize()
	//Make lists associative for lookup
	for(var/id in prereq_ids)
		prereq_ids[id] = TRUE
	for(var/id in design_ids)
		design_ids[id] = TRUE
	for(var/id in unlock_ids)
		unlock_ids[id] = TRUE

/datum/techweb_node/Destroy()
	SSresearch.techweb_nodes -= id
	return ..()

/datum/techweb_node/proc/on_design_deletion(datum/design/D)
	prune_design_id(D.id)

/datum/techweb_node/proc/on_node_deletion(datum/techweb_node/TN)
	prune_node_id(TN.id)

/datum/techweb_node/proc/prune_design_id(design_id)
	design_ids -= design_id

/datum/techweb_node/proc/prune_node_id(node_id)
	prereq_ids -= node_id
	unlock_ids -= node_id

/datum/techweb_node/proc/get_price(datum/techweb/host)
	if(!host)
		return research_costs

	var/list/actual_costs = research_costs.Copy()

	for(var/cost_type in actual_costs)
		for(var/experiment_type in discount_experiments)
			if(host.completed_experiments[experiment_type]) //do we have this discount_experiment unlocked?
				actual_costs[cost_type] -= discount_experiments[experiment_type]

	if(host.boosted_nodes[id]) // Boosts should be subservient to experiments. Discount from boosts are capped when costs fall below 250.
		var/list/boostlist = host.boosted_nodes[id]
		for(var/booster in boostlist)
			if(actual_costs[booster])
				var/delta = max(0, actual_costs[booster] - 250)
				actual_costs[booster] -= min(boostlist[booster], delta)

	return actual_costs

/datum/techweb_node/proc/is_free(datum/techweb/host)
	var/list/costs = get_price(host)
	var/total_points = 0

	for(var/point_type in costs)
		total_points += costs[point_type]

	if(total_points == 0)
		return TRUE
	return FALSE

/datum/techweb_node/proc/price_display(datum/techweb/TN)
	return techweb_point_display_generic(get_price(TN))

/datum/techweb_node/proc/on_research() //new proc, not currently in file
	return
