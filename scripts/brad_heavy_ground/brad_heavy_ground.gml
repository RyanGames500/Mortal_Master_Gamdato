function brad_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_heavy_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 13;
			
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
			
			if (attack_frame == 9) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 30;
				
				hsp = 6 * facing;
				
				var _hitbox = hitbox_create(110, -55, 1.8, 0.8, 18, 2);
				_hitbox.damage = 18;
				_hitbox.hitlag = 14;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				_hitbox.hit_angle = 25;
				_hitbox.hitstun = 40;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 26) then anim_frame = 4;
			if (attack_frame == 22) then anim_frame = 5;
			if (attack_frame == 18) then anim_frame = 6;
			if (attack_frame == 14) then anim_frame = 7;
			if (attack_frame == 10) then anim_frame = 8;
			if (attack_frame == 6)  then anim_frame = 9;
			if (attack_frame == 2)  then anim_frame = 10;
			
			if (attack_frame == 22)
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