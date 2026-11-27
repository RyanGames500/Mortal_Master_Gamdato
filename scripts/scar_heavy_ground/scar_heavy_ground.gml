function scar_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_heavy_ground;
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
			
			if (attack_frame == 6) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			if (attack_frame == 1) then anim_frame = 4;
			
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 24;
				
				hsp = 4 * facing;
				
			
				var _hitbox = hitbox_create(116, -36, 1.3, 0.9, 15, 5);
				_hitbox.hitlag = 12;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 8;
				_hitbox.hitstun = 16;      
				_hitbox.blockstun = 24;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			hsp = lerp(hsp, 0, 0.2);

			if (attack_frame == 20) then anim_frame = 6;
			if (attack_frame == 16) then anim_frame = 7;
			if (attack_frame == 12) then anim_frame = 8;
			if (attack_frame == 8)  then anim_frame = 9;
			if (attack_frame == 4)  then anim_frame = 10;
			if (attack_frame == 1)  then anim_frame = 11;
			
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