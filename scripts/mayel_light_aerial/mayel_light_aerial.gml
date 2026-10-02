function mayel_light_aerial(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mayel_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;
			
			//Hitbox
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 30;
				
				var _hitbox = hitbox_create(42, 37, 0.6, 0.3, 5, 2);
				_hitbox.image_angle = -33 * facing;
				_hitbox.high = true;
				_hitbox.knockback = 3;    // empuje bajo para poder seguirlo
				_hitbox.hitstun = 30;     // que no se recupere antes del siguiente golpe
				}
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground (antes de que salga el golpe: sin lag)
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Active and Endlag
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 20) then anim_frame = 2;
			if (attack_frame == 10) then anim_frame = 3;
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground
			if (bbox_bottom >= obj_ground.y)
				{
				if (attack_connected)
					{
					attack_stop();          // golpe conectado: aterriza libre
					}
				else
					{
					hsp = 0;                // golpe fallado: lag de aterrizaje
					vsp = 0;
					anim_frame = 3;
					attack_phase = 2;
					attack_frame = 8;
					}
				break;
				}
			
			//Cancel: si conectó, sube de fuerza
			if (attack_connected && attack_frame < 24)
				{
				if (input_pressed(INPUT.attack_light2))
					{
					attack_connected = false;
					attack_start(attacks[$ "medium_aerial"]);
					return;
					}
				if (input_pressed(INPUT.attack_heavy))
					{
					attack_connected = false;
					attack_start(attacks[$ "heavy_aerial"]);
					return;
					}
				}
			
			//Stop
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Landing lag (solo si el golpe aéreo falló)
		case 2:
			{
			attack_frame--;
			
			hsp = 0;
			vsp = 0;
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
/* Copyright 2024 Springroll Games / Yosi */