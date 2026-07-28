function blocky_heavy_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_blocky_heavy_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 20;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;
			
			//Throws
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			//Animation
			if (attack_frame == 18) then anim_frame = 1;
			if (attack_frame == 16) then anim_frame = 2;
			if (attack_frame == 14) then anim_frame = 3;
			if (attack_frame == 11) then anim_frame = 4;
			if (attack_frame == 8) then anim_frame = 5;
			if (attack_frame == 5) then anim_frame = 6;
			if (attack_frame == 3) then anim_frame = 7;
			if (attack_frame == 1) then anim_frame = 8;
			
			//Hitbox
			if (attack_frame == 0)
				{
				anim_frame = 9;
				attack_phase = 1;
				attack_frame = 45;
				hsp = 6 * facing;
				
				var _hitbox = hitbox_create(165, -68, 2.0, 2.0, 20, 4);
				_hitbox.sprite_index = spr_hitbox_circle;
				_hitbox.hitlag = 13;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				_hitbox.hitstun = 40;
				var _hitbox = hitbox_create(287, -200, 2.0, 2.0, 20, 4);
				_hitbox.sprite_index = spr_hitbox_circle;
				_hitbox.hitlag = 13;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				_hitbox.hitstun = 40;
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
			if (attack_frame == 43) then anim_frame = 10;
			if (attack_frame == 41) then anim_frame = 11;
			if (attack_frame == 38) then anim_frame = 12;
			if (attack_frame == 33) then anim_frame = 13;
			if (attack_frame == 28) then anim_frame = 14;
			if (attack_frame == 21) then anim_frame = 15;
			if (attack_frame == 14) then anim_frame = 16;
			if (attack_frame == 7) then anim_frame = 17;
			
			//Movement
			if (attack_frame == 43)
				{
				hsp = 0;
				}
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