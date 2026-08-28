function blitsen_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_heavy_crouch;
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
			
			// Crecimiento progresivo del brote
			if (attack_frame == 9) then anim_frame = 1;
			if (attack_frame == 6) then anim_frame = 2;
			if (attack_frame == 4) then anim_frame = 3;
			if (attack_frame == 2) then anim_frame = 4;
			
			// Mordisco y punto máximo en sub-imagen 5
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 24; // Recuperación más pesada
				
				var _hitbox = hitbox_create(95, -75, 1.2, 1.5, 11, 14);
				_hitbox.hitlag = 12;
				_hitbox.launch_speed = 13;
				_hitbox.knockback_angle = 75;
				_hitbox.knockback = 15;
				_hitbox.high = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			// Distribución fluida de retracción (24 frames)
			if (attack_frame == 21) then anim_frame = 6;
			if (attack_frame == 18) then anim_frame = 7;
			if (attack_frame == 15) then anim_frame = 8;
			if (attack_frame == 12) then anim_frame = 9;
			if (attack_frame == 9)  then anim_frame = 10;
			if (attack_frame == 6)  then anim_frame = 11;
			if (attack_frame == 3)  then anim_frame = 12;
			
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