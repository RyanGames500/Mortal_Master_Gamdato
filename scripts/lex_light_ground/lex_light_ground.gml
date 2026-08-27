function lex_light_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_light_ground;
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
				attack_frame = 18;

				var _hitbox = hitbox_create(96, -2, 0.9, 0.3, 5, 8);
				_hitbox.knockback = 5;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			if (attack_frame == 15) then anim_frame = 3;
			if (attack_frame == 12) then anim_frame = 4;
			if (attack_frame == 9)  then anim_frame = 5;
			if (attack_frame == 6)  then anim_frame = 6;
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