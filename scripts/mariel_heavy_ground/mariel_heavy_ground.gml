function mariel_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mariel_heavy_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 10;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup (frames 0 -> 3, impacto en 4)
		case 0:
			{
			attack_frame--;
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 7) then anim_frame = 1;
			if (attack_frame == 5) then anim_frame = 2;
			if (attack_frame == 3) then anim_frame = 3; // Puño atrás, carga
			
			//Hitbox: puñetazo (frame 4)
			if (attack_frame == 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 30;
				hsp = 3 * facing; // Pequeña embestida
				
				var _hitbox = hitbox_create(50, -30, 2.0, 1.8, 20, 4);
				_hitbox.sprite_index = spr_hitbox_circle;
				_hitbox.hitlag = 13;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				_hitbox.hitstun = 40;
				_hitbox.knockdown = true;
				}
			
			player_move();
			}
		break;
		
		//Active and Endlag (frames 5 -> 12)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 27) then anim_frame = 5;
			if (attack_frame == 24) then anim_frame = 6;
			if (attack_frame == 21) then anim_frame = 7;
			if (attack_frame == 18) then anim_frame = 8;
			if (attack_frame == 15) then anim_frame = 9;
			if (attack_frame == 11) then anim_frame = 10;
			if (attack_frame == 7)  then anim_frame = 11;
			if (attack_frame == 3)  then anim_frame = 12;
			
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