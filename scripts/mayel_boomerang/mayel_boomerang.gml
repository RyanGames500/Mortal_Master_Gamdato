function mayel_boomerang(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_boomerang;
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

			if (attack_frame == 8) then anim_frame = 1; 
			
			// LANZAMIENTO EN EL FRAME 3
			if (attack_frame == 4) 
				{
				anim_frame = 3; 
				attack_phase = 1;
				attack_frame = 16; 

				var _exists = false;
				with (obj_hitbox)
					{
					if (owner == other.id && custom_update == mayel_boomerang_update)
						{
						_exists = true;
						break;
						}
					}
				if (!_exists)
					{
					// hitbox_create(x_offset, y_offset, xscale, yscale, damage, lifetime)
					var _hitbox = hitbox_create(40, -30, 0.8, 0.8, 10, 0);
					_hitbox.lifetime = 999;
					_hitbox.destroy_on_stop = true; 
					_hitbox.custom_update = mayel_boomerang_update;
					_hitbox.custom_draw = mayel_boomerang_hitbox_draw;
					_hitbox.facing = facing;
					
					// Variables de estado del boomerang
					_hitbox.hsp = 14 * facing;
					_hitbox.vsp = 0;
					
					// Estados explícitos de control de vuelo
					_hitbox.boomerang_state = 0; // 0 = Ida / 1 = Frenando / 2 = Retorno
					_hitbox.brake_timer = 20;    // Frames que dura frenando en el aire
					_hitbox.has_hit_forward = false;
					_hitbox.has_hit_return = false;
					}
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			if (attack_frame == 11) then anim_frame = 3;
			if (attack_frame == 6)  then anim_frame = 4;
			if (attack_frame == 2)  then anim_frame = 5; 

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