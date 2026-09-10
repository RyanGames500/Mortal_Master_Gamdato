function scar_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 10;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 5) then anim_frame = 2;
			if (attack_frame == 3) then anim_frame = 3;
			if (attack_frame == 1) then anim_frame = 4;
			
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 27;
				
				hsp = 3 * facing;
				
				var _hitbox = hitbox_create(148, -69, 1.3, 0.9, 14, 10);
				_hitbox.hitlag = 12;
				_hitbox.knockback = 4;
				_hitbox.launch_speed = 14;
				_hitbox.hitstun = 38;
				_hitbox.blockstun = 24;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			hsp = lerp(hsp, 0, 0.2);

			if (attack_frame == 24) then anim_frame = 6;
			if (attack_frame == 21) then anim_frame = 7;
			if (attack_frame == 18) then anim_frame = 8;
			if (attack_frame == 15) then anim_frame = 9;
			if (attack_frame == 12) then anim_frame = 10;
			if (attack_frame == 9)  then anim_frame = 11;
			if (attack_frame == 6)  then anim_frame = 12;
			if (attack_frame == 3)  then anim_frame = 13;
			
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