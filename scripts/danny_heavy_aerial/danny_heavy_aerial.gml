function danny_heavy_aerial(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_danny_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0; // Control determinista por frames
			
			attack_frame = 5; // Startup aéreo ágil (5 frames)
			}
		break;
		
		//-------------------------------------------------------------
		//--- FASE 0: STARTUP AÉREO (Frames 0 -> 1) -------------------
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 10; // Ventana activa amplia de la patada
				
				// Hitbox Aérea Pesada: diagonal (arriba/adelante) con alto impacto
				var _hitbox = hitbox_create(32, -25, 1.6, 0.7, 9, 7);
				_hitbox.hitlag = 10;
				_hitbox.knockback = 11;
				_hitbox.launch_speed = 12;
				_hitbox.hitstun = 32;
				_hitbox.high = true; // No se bloquea agachado
				}
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground
			if (bbox_bottom >= obj_ground.y)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				hsp = 0;
				vsp = 0;
				anim_frame = 8;
				attack_phase = 3;
				attack_frame = 16; // Landing lag completo: aún no conectó
				break;
				}
			}
		break;
		
		//-------------------------------------------------------------
		//--- FASE 1: PATADA ACTIVA EN EL AIRE (Frames 2 -> 6) ---------
		//-------------------------------------------------------------
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 3;
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 4) then anim_frame = 5;
			if (attack_frame == 2) then anim_frame = 6;
			
			if (attack_frame <= 0)
				{
				anim_frame = 7;
				attack_phase = 2;
				
				// BALANCE AÉREO: más recuperación si falla
				if (attack_connected)
					{
					attack_frame = 8;  // Transición rápida si conecta
					}
				else
					{
					attack_frame = 18; // Recuperación mayor en el aire si falla
					}
				}
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground
			if (bbox_bottom >= obj_ground.y)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				hsp = 0;
				vsp = 0;
				anim_frame = 8;
				attack_phase = 3;
				attack_frame = attack_connected ? 6 : 16; // Menos castigo si conectó
				break;
				}
			}
		break;
		
		//-------------------------------------------------------------
		//--- FASE 2: RECOGIDA Y CAÍDA (Frames 7 -> 8) ----------------
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			if (attack_frame <= 10) then anim_frame = 8;
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground
			if (bbox_bottom >= obj_ground.y)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				hsp = 0;
				vsp = 0;
				anim_frame = 8;
				attack_phase = 3;
				attack_frame = attack_connected ? 6 : 16;
				break;
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//-------------------------------------------------------------
		//--- FASE 3: LANDING LAG (aterrizó durante el ataque) --------
		//-------------------------------------------------------------
		case 3:
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