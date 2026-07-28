function blocky_heavy_aerial(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_blocky_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			
			//Hitbox
			if (attack_frame == 0)
				{
				anim_frame = 4;
				attack_phase = 1;
				attack_frame = 35;
				
				var _hitbox = hitbox_create(90, -8, 1.2, 1.5, 15, 2);
				_hitbox.knockback = 20;
				_hitbox.hitlag = 12;
				_hitbox.sprite_index = spr_hitbox_circle;
				_hitbox.high = true;
				}
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Active and Endlag
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 33) then anim_frame = 5;
			if (attack_frame == 31) then anim_frame = 6;
			if (attack_frame == 29) then anim_frame = 7;
			if (attack_frame == 27) then anim_frame = 8;
			if (attack_frame == 24) then anim_frame = 9;
			if (attack_frame == 20) then anim_frame = 10;
			if (attack_frame == 15) then anim_frame = 11;
			if (attack_frame == 10) then anim_frame = 12;
			if (attack_frame == 5) then anim_frame = 13;
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			
			//Stop
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