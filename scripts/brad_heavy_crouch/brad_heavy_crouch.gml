function brad_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 11;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 1;
			if (attack_frame == 3) then anim_frame = 2;
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 28;
				
				hsp = 3 * facing;
				
				var _hitbox = hitbox_create(70, -110, 1.4, 1.6, 16, 2);
				_hitbox.damage = 16;
				_hitbox.hitlag = 10;
				_hitbox.knockback = 18;
				_hitbox.launch_speed = 18;
				_hitbox.hit_angle = 80;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 24) then anim_frame = 4;
			if (attack_frame == 19) then anim_frame = 5;
			if (attack_frame == 14) then anim_frame = 6;
			if (attack_frame == 10) then anim_frame = 7;
			if (attack_frame == 6)  then anim_frame = 8;
			if (attack_frame == 2)  then anim_frame = 9;
			
			if (attack_frame == 20)
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