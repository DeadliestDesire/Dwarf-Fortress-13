///LAVA

/turf/open/lava
	name = "lava"
	icon = 'dwarfs/icons/turf/lava.dmi'
	icon_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_LAVA)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_LAVA)
	gender = PLURAL //"That's some lava."
	baseturfs = /turf/open/lava //lava all the way down
	slowdown = 2

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	bullet_bounce_sound = 'sound/items/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	/// How much fire damage we deal to living mobs stepping on us
	var/lava_damage = 20
	/// How many firestacks we add to living mobs stepping on us
	var/lava_firestacks = 20
	/// How much temperature we expose objects with
	var/temperature_damage = 10000

	var/spread = FALSE

	var/turf/open/lava/magmus_top

/turf/open/lava/Initialize(mapload)
	. = ..()
	if(!spread)
		return
	update_lava_effect()

/turf/open/lava/proc/update_lava_effect()
	if(!spread)
		return

	LAZYADD(SSliquids.liquid_turfs_list, src)

	var/turf/top_turf = SSmapping.get_turf_above(src)
	if(isopenspace(top_turf))
		magmus_top = top_turf.ChangeTurf(/turf/open/lava)

/turf/open/lava/spread_liquid()
	var/list/temp_turf_list = list()
	for(var/direction in GLOB.cardinals)
		temp_turf_list += get_step(src, direction)

	for(var/turf/T as() in temp_turf_list)

		if(!T || isclosedturf(T) || islava(T))
			continue

		T.ChangeTurf(/turf/open/lava)

	return TRUE

/turf/open/lava/Destroy(force)
	if(magmus_top)
		magmus_top.ChangeTurf(/turf/open/openspace)
	. = ..()

/turf/open/lava/ex_act(severity, target)
	contents_explosion(severity, target)

/turf/open/lava/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/lava/Melt()
	return src

/turf/open/lava/acid_act(acidpwr, acid_volume)
	return FALSE

/turf/open/lava/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/lava/Entered(atom/movable/AM)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/Exited(atom/movable/Obj, atom/newloc)
	. = ..()
	if(isliving(Obj))
		var/mob/living/L = Obj
		if(!islava(newloc))
			REMOVE_TRAIT(L, TRAIT_PERMANENTLY_ONFIRE, TURF_TRAIT)
		if(!L.on_fire)
			L.update_fire()

/turf/open/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/process(delta_time)
	if(!burn_stuff(null, delta_time))
		STOP_PROCESSING(SSobj, src)

/turf/open/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/lava/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list())
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	return LAZYLEN(found_safeties)


/turf/open/lava/proc/burn_stuff(AM, delta_time = 1)
	. = 0

	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = 1
			if((O.resistance_flags & (ON_FIRE)))
				continue
			if(!(O.resistance_flags & FLAMMABLE))
				O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
			if(O.resistance_flags & FIRE_PROOF)
				O.resistance_flags &= ~FIRE_PROOF
			if(O.armor?.fire > 50) //obj with 100% fire armor still get slowly burned away.
				O.armor = O.armor.setRating(fire = 50)
			O.fire_act(temperature_damage, 1000 * delta_time)
			if(istype(O, /obj/structure/closet))
				var/obj/structure/closet/C = O
				for(var/I in C.contents)
					burn_stuff(I)
		else if (isliving(thing))
			. = 1
			var/mob/living/L = thing
			if(L.movement_type & FLYING)
				continue	//YOU'RE FLYING OVER IT
			var/buckle_check = L.buckled
			if(isobj(buckle_check))
				var/obj/O = buckle_check
				if(O.resistance_flags & LAVA_PROOF)
					continue
			else if(isliving(buckle_check))
				var/mob/living/live = buckle_check
				if(WEATHER_LAVA in live.weather_immunities)
					continue

			if(iscarbon(L))
				var/mob/living/carbon/C = L
				var/obj/item/clothing/S = C.get_item_by_slot(ITEM_SLOT_OCLOTHING)
				var/obj/item/clothing/H = C.get_item_by_slot(ITEM_SLOT_HEAD)

				if(S && H && S.clothing_flags & LAVAPROTECT && H.clothing_flags & LAVAPROTECT)
					return

			if(WEATHER_LAVA in L.weather_immunities)
				continue

			ADD_TRAIT(L, TRAIT_PERMANENTLY_ONFIRE,TURF_TRAIT)
			L.update_fire()

			L.adjustFireLoss(lava_damage * delta_time)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(lava_firestacks * delta_time)
				L.IgniteMob()
