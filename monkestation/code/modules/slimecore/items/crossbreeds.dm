/obj/item/slimecross
	icon = 'monkestation/code/modules/slimecore/icons/slimecrossing_plort_version.dmi'

// Ensure the industrial extract is always layered below the extract
/obj/item/slimecross/industrial/do_after_spawn(obj/item/spawned)
	spawned.layer = min(spawned.layer, layer - 0.1)
