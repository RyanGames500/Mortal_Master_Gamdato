function bear_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_bear_light_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 18;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 12) then anim_frame = 1;
			if (attack_frame == 9)  then anim_frame = 2;
			if (attack_frame == 5)  then anim_frame = 3;
			if (attack_frame == 2)  then anim_frame = 4;
			
			if (attack_frame == 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 30;
				
				var _hitbox = hitbox_create(300, -23, 1.6, 0.6, 10, 2);
				_hitbox.knockback = 45;
				_hitbox.hitstun = 30
				_hitbox.launch_speed = 15;
				_hitbox.knockdown = true;
				boss_hit_weight(_hitbox, 3);
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 29) then anim_frame = 6;
			if (attack_frame == 28) then anim_frame = 7;
			if (attack_frame == 23) then anim_frame = 8;
			if (attack_frame == 18) then anim_frame = 9;
			if (attack_frame == 13) then anim_frame = 10;
			if (attack_frame == 9)  then anim_frame = 11;
			if (attack_frame == 5)  then anim_frame = 12;
			
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