function lex_shotgun(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_shotgun;
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 6;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			if (attack_frame <= 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 24;

				// Retroceso del personaje por el disparo
				hsp = -7 * facing;

				// Generar ráfaga de 3 perdigones 
				var _bullet_speeds_y = [-3, 0, 3];
				
				for (var i = 0; i < 3; i++)
					{
					var _hitbox = hitbox_create(100, -85, 0.2, 0.2, 5, 15);
					_hitbox.owner = id;
					_hitbox.lifetime = 12;
					_hitbox.hitstun = 18;
					_hitbox.knockback = 12;
					_hitbox.launch_speed = 10;
					_hitbox.destroy_on_stop = true;
					_hitbox.custom_update = lex_shotgun_hitbox_update;
					_hitbox.custom_draw = lex_shotgun_hitbox_draw;
					
					// Trayectoria de los perdigones
					_hitbox.hsp = 22 * facing;
					_hitbox.vsp = _bullet_speeds_y[i];
					}
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			hsp *= knockback_friction;

			if (attack_frame == 18) then anim_frame = 2;
			if (attack_frame == 12) then anim_frame = 3;
			if (attack_frame == 6)  then anim_frame = 4;

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