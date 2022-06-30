/turf/closed/mineral/random/dwarf_lustress
	icon = 'dwarfs/icons/turf/walls_cavern.dmi'
	smooth_icon = 'dwarfs/icons/turf/walls_cavern.dmi'
	icon_state = "rockwall-0"
	base_icon_state = "rockwall"
	environment_type = "stone_raw"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	canSmoothWith = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	turf_type = /turf/open/floor/stone/raw
	baseturfs = /turf/open/floor/stone/raw
	mineralSpawnChanceList = list(/obj/item/stack/ore/gold = 5, /obj/item/stack/ore/iron = 40, /obj/item/stack/ore/gem/diamond=1,/obj/item/stack/ore/gem/ruby=1,/obj/item/stack/ore/gem/sapphire=1,/obj/item/stack/ore/coal=20)
	mineralChance = 5

/turf/closed/mineral/random/dwarf_lustress/Initialize()
	. = ..()
	transform = null

/turf/closed/mineral/random/dwarf_lustress/gets_drilled(user, give_exp = FALSE)
	. = ..()

	if(prob(0.3))
		to_chat(user, span_userdanger("THIS ROCK APPEARS TO BE ESPECIALLY SOFT!"))
		new /mob/living/simple_animal/hostile/troll(src)

/turf/closed/mineral/random/dwarf_lustress/attackby_secondary(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pickaxe) && params)
		playsound(src, pick(I.usesound), 100, TRUE)
		if(do_after(user, 10 SECONDS, target = src))
			if(QDELETED(src))
				return
			var/turf/TA = SSmapping.get_turf_above(src)
			if(istype(TA, /turf/closed/mineral) || istype(TA, /turf/open/floor/stone/raw))
				TA.ChangeTurf(/turf/open/openspace)
				var/turf/TT = ChangeTurf(/turf/open/floor/stone/raw)
				var/obj/O = new /obj/structure/stairs(TT)
				O.dir = user.dir
				user.visible_message(span_notice("<b>[user]</b> constructs stairs upwards") , \
									span_notice("You construct stairs upwards."))
			else
				to_chat(user, span_warning("Something very dense above!"))
	return ..()

/turf/closed/wall/stonewall
	name = "stone wall"
	desc = "Just a regular stone wall."
	icon = 'dwarfs/icons/turf/walls_dwarven.dmi'
	icon_state = "rich_wall-0"
	base_icon_state = "rich_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	canSmoothWith = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	sheet_type = /obj/item/stack/sheet/stone
	baseturfs = /turf/open/floor/stone
	sheet_amount = 4
	girder_type = null
