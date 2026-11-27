function scar_light_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_light_crouch;
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

			if (attack_frame == 3) then anim_frame = 1;
			if (attack_frame == 1) then anim_frame = 2;

			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 12;

				var _hitbox = hitbox_create(76, 147, 1.1, 0.3, 5, 4);
				_hitbox.knockback = 4;
				_hitbox.hitstun = 16;
				_hitbox.blockstun = 12;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			if (attack_frame == 9) then anim_frame = 4;
			if (attack_frame == 6) then anim_frame = 5;
			if (attack_frame == 3) then anim_frame = 6;
			if (attack_frame == 1) then anim_frame = 7;

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