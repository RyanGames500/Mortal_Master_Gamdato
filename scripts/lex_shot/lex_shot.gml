function lex_shot(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_shot;
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 8;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			if (attack_frame == 5) then anim_frame = 1;

			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 22;

				hsp = -15 * facing;

				var _exists = false;
				with (obj_hitbox)
					{
					if (owner == other.id && custom_update == lex_shot_hitbox_update)
						{
						_exists = true;
						break;
						}
					}
				if (!_exists)
					{
					var _hitbox = hitbox_create(112, -3, 0.7, 0.7, 10, 150);
					_hitbox.destroy_on_stop = false;
					_hitbox.custom_update = lex_shot_hitbox_update;
					_hitbox.custom_draw = lex_shot_hitbox_draw;
					
					if (stick_check_direction(STICK_DIR.backward_any))
						{
						_hitbox.hsp = 15 * facing;
						}
					else
						{
						_hitbox.hsp = 25 * facing;
						}
					_hitbox.facing = facing;
					}
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			hsp *= knockback_friction;

			if (attack_frame == 19) then anim_frame = 3;
			if (attack_frame == 15) then anim_frame = 4;
			if (attack_frame == 11) then anim_frame = 5;
			if (attack_frame == 7)  then anim_frame = 6;
			if (attack_frame == 3)  then anim_frame = 7;

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