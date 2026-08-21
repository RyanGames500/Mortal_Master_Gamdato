function lex_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_heavy_ground;
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

			if (attack_frame == 7) then anim_frame = 1;
			if (attack_frame == 6) then anim_frame = 2;
			if (attack_frame == 5) then anim_frame = 3;
			if (attack_frame == 4) then anim_frame = 4;
			if (attack_frame == 3) then anim_frame = 5;
			if (attack_frame == 2) then anim_frame = 6;
			if (attack_frame == 1) then anim_frame = 7;

			if (attack_frame <= 0)
				{
				anim_frame = 8;
				attack_phase = 1;
				attack_frame = 26;

				var _hitbox = hitbox_create(90, -35, 1, 0.8, 14, 12);
				_hitbox.sprite_index = spr_hitbox_square;
				_hitbox.hitlag = 14;
				_hitbox.knockback = 18;
				_hitbox.launch_speed = 18;
				_hitbox.hitstun = 40;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			if (attack_frame == 18) then anim_frame = 9;
			if (attack_frame == 9)  then anim_frame = 10;

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