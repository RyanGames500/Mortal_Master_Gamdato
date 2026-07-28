function blocky_hadoken(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_blocky_hadoken;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 15;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 12) then anim_frame = 1;
			if (attack_frame == 9) then anim_frame = 2;
			if (attack_frame == 5) then anim_frame = 3;
			if (attack_frame == 2) then anim_frame = 4;
			
			//Hitbox
			if (attack_frame == 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 33;
				
				//You can't spawn a Hadoken if there is already one
				var _exists = false;
				with (obj_hitbox)
					{
					if (owner == other.id && custom_update == blocky_hadoken_hitbox_update)
						{
						_exists = true;
						break;
						}
					}
				if (!_exists)
					{
					var _hitbox = hitbox_create(112, 3, 0.7, 0.7, 10, 120);
					_hitbox.destroy_on_stop = true;
					_hitbox.custom_update = blocky_hadoken_hitbox_update;
					_hitbox.custom_draw = blocky_hadoken_hitbox_draw;
					if (stick_check_direction(STICK_DIR.backward_any))
						{
						_hitbox.hsp = 5 * facing;
						}
					else
						{
						_hitbox.hsp = 10 * facing;
						}
					_hitbox.facing = facing;
					}
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Active and Endlag
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 31) then anim_frame = 6;
			if (attack_frame == 24) then anim_frame = 7;
			if (attack_frame == 16) then anim_frame = 8;
			if (attack_frame == 8) then anim_frame = 9;
			
			//Movement
			player_move();
			
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