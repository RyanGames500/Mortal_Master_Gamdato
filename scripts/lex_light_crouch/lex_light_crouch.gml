function lex_light_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_light_crouch;
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 4;

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

				var _hitbox = hitbox_create(75, 10, 1.2, 0.4, 5, 30);
				_hitbox.knockback = 10;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			if (attack_frame == 14) then anim_frame = 3;
			if (attack_frame == 11) then anim_frame = 4;
			if (attack_frame == 8)  then anim_frame = 5;
			if (attack_frame == 6)  then anim_frame = 6;
			if (attack_frame == 4)  then anim_frame = 7;
			if (attack_frame == 2)  then anim_frame = 8;

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