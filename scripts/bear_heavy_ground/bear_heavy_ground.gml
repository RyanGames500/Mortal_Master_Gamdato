function bear_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_bear_heavy_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 9;
			
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
			
			if (attack_frame == 5) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 17;
				
				var _hitbox = hitbox_create(128, -6, 1, 1.5, 30, 3);
				_hitbox.knockback = 45;
				_hitbox.hitstun = 45;
				_hitbox.launch_speed = 35;
				_hitbox.knockdown = true;
				boss_hit_weight(_hitbox, 3);
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 3;
			if (attack_frame == 12) then anim_frame = 4;
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 7)  then anim_frame = 6;
			if (attack_frame == 4)  then anim_frame = 7;
			
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