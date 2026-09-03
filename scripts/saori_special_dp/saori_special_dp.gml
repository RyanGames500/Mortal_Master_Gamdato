function saori_special_dp(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_special_shoryu;
			anim_frame = 0; // Frame 0: Preparación / Flexión
			anim_speed = 0;
			
			attack_frame = 3;
			
			hsp = 0;
			vsp = 0;
			
			invincible = true;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 1; // Inicia el impacto del gancho
				attack_phase = 1;
				attack_frame = 28;
				
				// Elevación explosiva
				hsp = 7 * facing;
				vsp = -25;
				
				invincible = true;
				
				// HITBOX INICIAL (Frame 2 del sprite con la estela de energía)
				var _hitbox = hitbox_create(76.5, -74, 0.6, 1, 10, 5);
				_hitbox.hitlag = 12;
				_hitbox.launch_speed = 20;
				_hitbox.knockback = 12;
				_hitbox.angle = 85;
				_hitbox.hitstun = 40;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			// Quita invulnerabilidad tras pasar los frames de impacto activo
			if (attack_frame < 24)
				{
				invincible = false;
				}

			// Gravedad y física
			vsp += grav;

			// TIMELINE DE ANIMACIÓN Y HITBOX TARDÍA
			if (attack_frame == 26) then anim_frame = 2; // Estela de impacto completa
			
			if (attack_frame == 24)
				{
				anim_frame = 3; // Punto más alto con destellos de energía
				
				// HITBOX TARDÍA (Frames aéreos continuos)
				var _hitbox_late = hitbox_create(76, -74, 0.7, 1, 6, 8);
				_hitbox_late.hitlag = 8;
				_hitbox_late.launch_speed = 12;
				_hitbox_late.knockback = 8;
				_hitbox_late.angle = 75;
				_hitbox_late.hitstun = 25;
				}

			// Transición de caída en el aire (Frames 4, 5, 6, 7)
			if (attack_frame == 18) then anim_frame = 4;
			if (attack_frame == 12) then anim_frame = 5;
			if (attack_frame == 6)  then anim_frame = 6;
			if (attack_frame == 2)  then anim_frame = 7;
			
			player_move();
			
			// Si toca el suelo recupera estado
			if (bbox_bottom >= obj_ground.y && attack_frame < 20)
				{
				attack_stop();
				break;
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}