function bear_charge(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_bear_embestida;	// sprite nuestro: la hoja de 6 cuadros
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 14;	// preparación (cuadros 0 y 1)
			
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
			
			// La segunda pose de la preparación
			if (attack_frame == 7) then anim_frame = 1;
			
			// Arranca la embestida
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 28;
				hsp = 35 * facing;
				
				var _hitbox = hitbox_create(100, -58, 1.3, 1.5, 20, 15);
				_hitbox.launch_speed = 10;
				_hitbox.high = true;
				_hitbox.knockback = 35;
				_hitbox.knockdown = true;
				_hitbox.launch_speed = 15;
				boss_hit_weight(_hitbox, 3);
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 24) then anim_frame = 3;
			if (attack_frame == 16) then anim_frame = 4;
			if (attack_frame == 8)  then anim_frame = 5;
			
			// Frena al final para que no corte de golpe (nuestro)
			if (attack_frame < 8) then hsp *= 0.75;
			
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