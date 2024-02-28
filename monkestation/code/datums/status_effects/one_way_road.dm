#define EXPLOSION_ANTISPAM_COOLDOWN		2 SECONDS

/datum/status_effect/one_way_road
	id = "one_way_road"
	tick_interval = -1
	/// The multiplier given to the speed of deflected projectiles. Lower = faster.
	var/projectile_speed_mul = 0.8
	/// The multiplier given to the damage of deflected projectiles.
	var/projectile_damage_mul = 1.15
	/// Cooldown for preventing spam messages about explosions being deflected.
	COOLDOWN_DECLARE(explosion_antispam)

/datum/status_effect/one_way_road/on_apply()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_ATOM_EMP_ACT, PROC_REF(nullify_emp))
	RegisterSignal(owner, COMSIG_ATOM_PRE_EX_ACT, PROC_REF(deflect_explosion))
	RegisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(deflect_projectile))
	RegisterSignal(owner, COMSIG_ATOM_BLOB_ACT, PROC_REF(reflect_blob))

/datum/status_effect/one_way_road/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_ATOM_EMP_ACT, COMSIG_ATOM_PRE_EX_ACT, COMSIG_ATOM_PRE_BULLET_ACT, COMSIG_ATOM_BLOB_ACT))

/datum/status_effect/one_way_road/proc/nullify_emp(datum/source, severity)
	SIGNAL_HANDLER
	return EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS | EMP_PROTECT_WIRES

/datum/status_effect/one_way_road/proc/deflect_explosion(datum/source, severity, atom/target)
	SIGNAL_HANDLER
	if(COOLDOWN_FINISHED(src, explosion_antispam))
		owner.visible_message(span_warning("The explosive shockwave flows around [owner], leaving [owner.p_them()] completely untouched!"))
		COOLDOWN_START(src, explosion_antispam, EXPLOSION_ANTISPAM_COOLDOWN)
	return COMPONENT_CANCEL_EX_ACT

/datum/status_effect/one_way_road/proc/deflect_projectile(datum/source, obj/projectile/projectile, def_zone)
	SIGNAL_HANDLER
	if(istype(projectile, /obj/projectile/magic/resurrection))
		return
	. = COMPONENT_BULLET_PIERCED
	var/atom/movable/sender = projectile.firer
	if(sender in owner.get_all_linked_holoparasites())
		return
	projectile.speed *= projectile_speed_mul
	projectile.damage *= projectile_damage_mul
	if(sender == owner)
		projectile.set_angle(rand(0, 360))
		owner.visible_message(span_danger("An invisible force around [owner] deflects [projectile] away from [owner.p_them()]!"), vision_distance = COMBAT_MESSAGE_RANGE)
	else
		// return to sender
		projectile.firer = owner
		projectile.original = sender
		projectile.set_angle(get_angle(owner, sender))
		// haha fuck you
		projectile.homing = TRUE
		projectile.homing_turn_speed = max(20, projectile.homing_turn_speed)
		projectile.set_homing_target(sender)
		owner.visible_message(span_danger("An invisible force around [owner] deflects [projectile] away from [owner.p_them()], sending it directly back at [sender]!"), vision_distance = COMBAT_MESSAGE_RANGE)

/datum/status_effect/one_way_road/proc/reflect_blob(datum/source, obj/structure/blob/attacking_blob)
	SIGNAL_HANDLER
	owner.visible_message(span_danger("An invisible force strikes [attacking_blob] as it lashes out at [owner], reflecting its attack!"), vision_distance = COMBAT_MESSAGE_RANGE)
	attacking_blob.take_damage(attacking_blob.max_integrity * 0.5)
	return COMPONENT_CANCEL_BLOB_ACT

#undef EXPLOSION_ANTISPAM_COOLDOWN
