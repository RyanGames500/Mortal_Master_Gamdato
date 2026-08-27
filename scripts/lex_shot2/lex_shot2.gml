function lex_shot2(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_shot2;
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 5;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			if (attack_frame == 2) then anim_frame = 1;

			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 16;

				hsp = -3 * facing;

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
					var _hitbox = hitbox_create(134, -112, 0.4, 0.4, 6, 12);
					_hitbox.destroy_on_stop = true;
					_hitbox.custom_update = lex_shot2_hitbox_update;
					_hitbox.custom_draw = lex_shot2_hitbox_draw;
					_hitbox.facing = facing;
					
					if (stick_check_direction(STICK_DIR.backward_any))
						{
						_hitbox.hsp = 16 * facing;
						}
					else
						{
						_hitbox.hsp = 24 * facing;
						}
					}
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			hsp *= knockback_friction;

			if (attack_frame == 12) then anim_frame = 3;
			if (attack_frame == 6)  then anim_frame = 4;

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