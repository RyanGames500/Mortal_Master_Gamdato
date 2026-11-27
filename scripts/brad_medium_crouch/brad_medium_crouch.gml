function brad_medium_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_medium_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 1;
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 24;
				
				hsp = 5 * facing;
				
				var _hitbox = hitbox_create(80, -10, 1.2, 0.4, 8, 12);
				_hitbox.low = true;
				_hitbox.knockback = 10;
				_hitbox.launch_speed = 10;
				_hitbox.hit_angle = 30;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 16) then anim_frame = 4;
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 4)  then anim_frame = 6;
			
			if (attack_frame == 14)
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