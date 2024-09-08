/world/SetupLogs()
	. = ..()
	if(GLOB.log_directory && SSdbcore.IsConnected())
		var/datum/db_query/query_log_directory = SSdbcore.NewQuery(
			"UPDATE [format_table_name("round")] SET log_directory = :log_directory WHERE id = :round_id",
			list("log_directory" = "[GLOB.log_directory]", "round_id" = GLOB.round_id)
		)
		query_log_directory.Execute()
		qdel(query_log_directory)
