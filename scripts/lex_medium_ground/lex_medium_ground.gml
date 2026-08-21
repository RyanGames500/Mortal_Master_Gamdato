function lex_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_medium_ground;
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 3;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			//if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
			//	{
			//	attack_start(attacks[$ "throw"]);
			//	return;
			//	}

			if (attack_frame <= 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 18;

				var _hitbox = hitbox_create(250, -91, 1.7, 0.3, 6, 5);
				_hitbox.knockback = 7;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			if (attack_frame == 15) then anim_frame = 2;
			if (attack_frame == 12) then anim_frame = 3;
			if (attack_frame == 9)  then anim_frame = 4;
			if (attack_frame == 6)  then anim_frame = 5;
			if (attack_frame == 3)  then anim_frame = 6;
			if (attack_frame == 1)  then anim_frame = 7;

			player_move();

			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */