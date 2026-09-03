function saori_special_divekick(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_special_divekick;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 2; // Pausa mínima en el aire para arranque instantáneo
			
			hsp = 1 * facing;
			vsp = -1;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 20;
				
				// CAÍDA RÁPIDA: Velocidad diagonal explosiva hacia el piso
				hsp = 14 * facing;
				vsp = 16;
				
				var _hitbox = hitbox_create(73, 67, 1.2, 0.8, 10, 8);
				_hitbox.hitlag = 8;
				_hitbox.knockback = 8;
				_hitbox.hitstun = 24;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			anim_frame = 1 + ((20 - attack_frame) div 2) % 6;

			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				attack_phase = 2;
				attack_frame = 5; // Landing lag corto para mantener la fluidez
				
				hsp = 4 * facing;
				vsp = 0;
				anim_frame = 7;
				break;
				}

			if (attack_frame <= 0)
				{
				attack_phase = 2;
				attack_frame = 5;
				anim_frame = 7;
				break;
				}
			}
		break;

		case 2:
			{
			attack_frame--;

			hsp = max(0, abs(hsp) - 0.8) * facing;

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