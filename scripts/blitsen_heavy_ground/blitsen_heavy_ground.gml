function blitsen_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_heavy_ground;
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
			
			//if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
			//	{
			//	attack_start(attacks[$ "throw"]);
			//	return;
			//	}
			
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 5) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			
			if (attack_frame <= 0)
				{
				anim_frame = 4;
				attack_phase = 1;
				attack_frame = 22;
				
				var _hitbox = hitbox_create(85, -35, 1.4, 0.6, 12, 14);
				_hitbox.hitlag = 13;
				_hitbox.launch_speed = 12;
				_hitbox.knockback = 18;
				_hitbox.high = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 18) then anim_frame = 5;
			if (attack_frame == 13) then anim_frame = 6;
			if (attack_frame == 8)  then anim_frame = 7;
			if (attack_frame == 4)  then anim_frame = 8;
			
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