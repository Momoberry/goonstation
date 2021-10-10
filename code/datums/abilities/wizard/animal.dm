var/list/animal_spell_critter_paths = list(/mob/living/critter/small_animal/cat,
/mob/living/critter/small_animal/dog,
/mob/living/critter/small_animal/dog/corgi,
/mob/living/critter/small_animal/dog/shiba,
/mob/living/critter/small_animal/bird/random,
/mob/living/critter/small_animal/bird/owl,
/mob/living/critter/small_animal/bird/turkey,
/mob/living/critter/small_animal/bird/timberdoodle,
/mob/living/critter/small_animal/bird/seagull,
/mob/living/critter/small_animal/bird/crow,
/mob/living/critter/small_animal/bird/goose,
/mob/living/critter/small_animal/bird/goose/swan,
/mob/living/critter/small_animal/floateye,
/mob/living/critter/small_animal/pig,
/mob/living/critter/spider/clown,
/mob/living/critter/small_animal/bat,
/mob/living/critter/small_animal/bat/angry,
/mob/living/critter/spider/nice,
/mob/living/critter/spider/baby,
/mob/living/critter/spider/ice/baby,
/mob/living/critter/small_animal/wasp,
/mob/living/critter/small_animal/raccoon,
/mob/living/critter/small_animal/seal,
/mob/living/critter/small_animal/walrus,
/mob/living/critter/small_animal/slug,
/mob/living/critter/small_animal/slug/snail,
/mob/living/critter/small_animal/bee,
/mob/living/critter/maneater_polymorph,			//because
/mob/living/critter/fermid_polymorph,
/mob/living/critter/small_animal/crab_polymorph,)

/datum/targetable/spell/animal
	name = "Baleful Polymorph" // todo: a decent name - done?
	desc = "Turns the target into a creature of some sort."
	icon_state = "animal"
	targeted = 1
	max_range = 1
	cooldown = 1200
	requires_robes = 1
	offensive = 1
	sticky = 1
	voice_grim = "sound/voice/wizard/FurryGrim.ogg"
	voice_fem = "sound/voice/wizard/FurryFem.ogg"
	voice_other = "sound/voice/wizard/FurryLoud.ogg"

	cast(mob/target)
		if (!holder)
			return
		var/mob/living/carbon/human/H = target
		if (!istype(H))
			boutput(holder.owner, "Your target must be human!")
			return 1
		holder.owner.visible_message("<span class='alert'><b>[holder.owner] begins to cast a spell on [target]!</b></span>")
		if (do_mob(holder.owner, target, 20))
			if(!istype(get_area(holder.owner), /area/sim/gunsim))
				holder.owner.say("YORAF UHRY") // AN EMAL? PAL EMORF? TURAN SPHORM?
			..()

			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(5, 0, H.loc)
			smoke.attach(H)
			smoke.start()

			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='alert'>[H] has divine protection from magic.</span>")
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
				JOB_XP(H, "Chaplain", 2)
				return

			if (iswizard(H))
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
				return

			if (check_target_immunity( H ))
				H.visible_message("<span class='alert'>[H] seems to be warded from the effects!</span>")
				return 1

			if (H.mind && (H.mind.assigned_role != "Animal") || (!H.mind || !H.client))
				boutput(H, "<span class='alert'><B>You feel your flesh painfully ripped apart and reformed into something else!</B></span>")
				if (H.mind)
					H.mind.assigned_role = "Animal"
				H.emote("scream", 0)

				H.unequip_all()
				var/mob/living/critter/C = H.make_critter(pick(animal_spell_critter_paths))
				C.real_name = "[H.real_name] the [C.real_name]"
				C.name = C.real_name
				if (istype(C, /mob/living/critter/small_animal/bee))
					var/mob/living/critter/small_animal/bee/B = C
					B.non_admin_bee_allowed = 1
				if (istype(C))
					C.change_misstep_chance(30)
					C.stuttering = 40
					SHOW_POLYMORPH_TIPS(C)
		else
			return 1
