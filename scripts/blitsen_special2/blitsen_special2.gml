function blitsen_special2(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_special2;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 9) then anim_frame = 1;
			if (attack_frame == 6) then anim_frame = 2;
			if (attack_frame == 3) then anim_frame = 3;
			
			if (attack_frame <= 0)
				{
				anim_frame = 4;
				attack_phase = 1;
				attack_frame = 32;
				
				var _hitbox = hitbox_create(599, 56, 1.6, 1.6, 13, 15);
				_hitbox.hitlag = 12;
				_hitbox.launch_speed = 12;
				_hitbox.knockback = 18;
				_hitbox.low = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 27) then anim_frame = 5;
			if (attack_frame == 22) then anim_frame = 6;
			if (attack_frame == 17) then anim_frame = 7;
			if (attack_frame == 12) then anim_frame = 8;
			if (attack_frame == 8)  then anim_frame = 9;
			if (attack_frame == 5)  then anim_frame = 10;
			if (attack_frame == 2)  then anim_frame = 11;
			
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