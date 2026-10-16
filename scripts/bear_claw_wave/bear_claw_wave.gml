function bear_claw_wave(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_bear_sarpazo;	// sprite nuestro: la hoja de 5 cuadros
			anim_frame = 0;
			anim_speed = 0;		// Determinista: cero image_speed para el rollback
			
			attack_frame = 12;	// preparación (cuadro 0)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PREPARACIÓN + PRIMER ZARPAZO (cuadro 0 | hitbox en el cuadro 1) ---
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			// Throws (solo si el personaje tiene agarre)
			// Este ataque se lanza con el botón medio, así que el agarre usa el fuerte
			if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Primer golpe -> cuadro 1 (el arco)
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 24;
				
				var _hitbox = hitbox_create(110, -58, 1.4, 1.3, 12, 5);
				_hitbox.hitstun = 25;
				_hitbox.blockstun = 15;
				_hitbox.knockdown = true;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				boss_hit_weight(_hitbox, 2);
				}
			
			player_move();
			}
		break;
		
		//-------------------------------------------------------------
		//--- SEGUNDO GOLPE: PROYECTIL RASTRERO (cuadros 2 -> 4) ---
		//-------------------------------------------------------------
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 21) then anim_frame = 2;
			
			// Sale la onda por el suelo -> cuadro 3
			if (attack_frame == 15)
				{
				anim_frame = 3;
				
				// No se crea otra onda si ya hay una de este personaje en pantalla
				var _exists = false;
				with (obj_hitbox)
					{
					if (owner == other.id && custom_update == bear_wave_hitbox_update)
						{
						_exists = true;
						break;
						}
					}
				if (!_exists)
					{
					var _hitbox = hitbox_create(300, 50, 0.9, 0.45, 10, 90);
					_hitbox.y = obj_ground.y - 40;		// a ras de suelo (nuestro: ajústalo viéndolo)
					_hitbox.knockdown = true;
					_hitbox.destroy_on_stop = true;
					_hitbox.custom_update = bear_wave_hitbox_update;
					_hitbox.custom_draw = bear_wave_hitbox_draw;
					_hitbox.low = true;				// hay que bloquearlo agachado
					_hitbox.grounded_only = true;		// se esquiva saltando
					_hitbox.hitstun = 25;
					_hitbox.blockstun = 15;
					_hitbox.knockback = 12;
					_hitbox.launch_speed = 20;
					_hitbox.hsp = 15 * facing;
					_hitbox.facing = facing;
					boss_hit_weight(_hitbox, 2);
					}
				}
			
			if (attack_frame == 8) then anim_frame = 4;
			
			player_move();
			
			// Fin del ataque
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}