function brad_roll(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_roll_ini;
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
			
			if (attack_frame == 0)
				{
				anim_sprite = spr_brad_Roll;
				anim_frame = 0;
				attack_phase = 1;
				attack_frame = 24;
				
				hsp = 20 * facing;
				
				var _hitbox = hitbox_create(40, -20, 1.2, 0.8, 10, 15);
				_hitbox.damage = 8;
				_hitbox.hitlag = 8;
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 12;
				_hitbox.hit_angle = 30;
				_hitbox.low = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			
			if (attack_frame == 21) then anim_frame = 1;
			if (attack_frame == 18) then anim_frame = 2;
			if (attack_frame == 15) then anim_frame = 3;
			if (attack_frame == 12) then anim_frame = 4;
			if (attack_frame == 9)  then anim_frame = 5;
			if (attack_frame == 6)  then anim_frame = 6;
			if (attack_frame == 3)  then anim_frame = 7;
			
			player_move();
			
			if (attack_frame <= 0)
				{
				anim_sprite = spr_brad_roll_ini;
				anim_frame = 3;
				attack_phase = 2;
				attack_frame = 8;
				}
			}
		break;
		
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 2;
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 0;
			
			hsp *= 0.5;
			player_move();
			
			if (attack_frame <= 0)
				{
				hsp = 0;
				attack_stop();
				break;
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */