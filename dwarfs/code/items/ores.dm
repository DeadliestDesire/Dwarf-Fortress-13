/datum/material/stone
	name = "stone"
	desc = "Oldfag."
	color = "#878687"
	sheet_type = /obj/item/stack/sheet/stone

/obj/item/stack/ore/stone
	name = "rock"
	icon = 'dwarfs/icons/items/ores_gems.dmi'
	icon_state = "rock"
	singular_name = "Rock piece"
	max_amount = 1
	merge_type = /obj/item/stack/ore/stone

/obj/item/stack/ore/stone/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_CHISEL)
		if(I.use_tool(src, user, 1 SECONDS, volume=50))
			if(prob(25))
				to_chat(user, span_warning("You process \the [src]."))
				return
			new /obj/item/stack/sheet/stone(user.loc)
			user.mind.adjust_experience(/datum/skill/mining, 1)
			to_chat(user, span_notice("You process \the [src]."))
			use(1)
	else
	 . = ..()

/obj/item/stack/sheet/stone
	name = "stone"
	desc = "Used in building."
	singular_name = "Brick"
	icon = 'dwarfs/icons/items/components.dmi'
	icon_state = "stone_brick"
	inhand_icon_state = "sheet-metal"
	force = 10
	throwforce = 10
	resistance_flags = FIRE_PROOF
	w_class = WEIGHT_CLASS_TINY
	merge_type = /obj/item/stack/sheet/stone
	material_type = /datum/material/stone

GLOBAL_LIST_INIT(stone_recipes, list(
	new/datum/stack_recipe("Pot", /obj/structure/sapling_pot, 20, time=60 SECONDS, tools=TOOL_CHISEL),
))

/obj/item/stack/sheet/stone/get_main_recipes()
	. = ..()
	. += GLOB.stone_recipes
