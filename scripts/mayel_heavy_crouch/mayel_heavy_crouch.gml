function mayel_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_heavy_crouch;
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
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 4) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 24;
				hsp = 4 * facing;
				
				 var _hitbox = hitbox_create(45, 36, 0.5, 0.3, 12, 4);
				_hitbox.low = true;
				_hitbox.hitlag = 10;
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 10;
				_hitbox.hit_angle = 75;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 16) then anim_frame = 4;
			if (attack_frame == 12) then anim_frame = 5;
			if (attack_frame == 8)  then anim_frame = 6;
			if (attack_frame == 4)  then anim_frame = 7;
			if (attack_frame == 2)  then anim_frame = 8;
			
			if (attack_frame == 18)
				{
				hsp = 0;
				}
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