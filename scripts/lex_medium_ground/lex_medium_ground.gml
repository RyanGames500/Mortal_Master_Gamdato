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

			attack_frame = 6;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			if (attack_frame == 3) then anim_frame = 1;

			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 25;

				var _hitbox = hitbox_create(74, -65, 0.5, 0.3, 6, 5);
				_hitbox.knockback = 9;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 15) then anim_frame = 4;
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 5)  then anim_frame = 6;

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