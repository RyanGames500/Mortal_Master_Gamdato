function brad_heavy_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//--- INIT ---
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 9; // Startup pesado aéreo (9 frames)
			}
		break;
		
		//--- STARTUP: Frames 0 -> 2 ---
		case 0:
			{
			attack_frame--;
			
			// Preparación de la patada
			if (attack_frame == 6) then anim_frame = 1;
			if (attack_frame == 3) then anim_frame = 2;
			
			// Hitbox activa al extender la pierna (Frame 3)
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 25; // Duración activa + recovery aéreo
				
				// HITBOX HEAVY AÉREA: Posicionada frente y abajo de la pierna (x: 85, y: 15)
				var _hitbox = hitbox_create(85, 15, 1.5, 1.3, 16, 22);
				_hitbox.damage = 15;
				_hitbox.hitlag = 12;
				_hitbox.knockback = 18;
				_hitbox.launch_speed = 18;
				_hitbox.hit_angle = 290; // Ángulo de meteoro/spike (manda al rival directo al suelo)
				_hitbox.hitstun = 35;
				}
			
			//Movement
			vsp += grav;
			player_move();
			
			// Landing cancel
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//--- ACTIVE & ENDLAG: Frames 3 -> 9 ---
		case 1:
			{
			attack_frame--;
			
			// Transición completa por las 10 sub-imágenes (0 a 9)
			if (attack_frame == 21) then anim_frame = 4;
			if (attack_frame == 17) then anim_frame = 5;
			if (attack_frame == 13) then anim_frame = 6;
			if (attack_frame == 9)  then anim_frame = 7;
			if (attack_frame == 5)  then anim_frame = 8;
			if (attack_frame == 2)  then anim_frame = 9; // Extensión final sostenida
			
			//Movement
			vsp += grav;
			player_move();
			
			// Landing cancel
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			
			//Stop
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