function scar_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_heavy_ground; // Tira de 12 subimágenes (0 a 11)
			anim_frame = 0;
			anim_speed = 0;
			
			// Startup pesado (8 frames) para cargar la patada
			attack_frame = 8;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			// Carga progresiva del torso y rodilla (frames 0 al 4)
			if (attack_frame == 6) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			if (attack_frame == 1) then anim_frame = 4;
			
			// Instante del golpe pesado (Subimagen 5: Impacto con ráfaga)
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 24; // Recovery largo por ser Heavy
				
				// Ligera zancada hacia adelante para dar alcance
				hsp = 4 * facing;
				
			
				var _hitbox = hitbox_create(116, -36, 1.3, 0.9, 15, 5);
				_hitbox.hitlag = 12;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 8;
				_hitbox.hitstun = 36;      
				_hitbox.blockstun = 24;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			// Frenar la inercia de la patada
			hsp = lerp(hsp, 0, 0.2);

			// Recorrido ordenado de los frames restantes (6 a 11)
			if (attack_frame == 20) then anim_frame = 6;  // Mantiene extensión
			if (attack_frame == 16) then anim_frame = 7;
			if (attack_frame == 12) then anim_frame = 8;
			if (attack_frame == 8)  then anim_frame = 9;
			if (attack_frame == 4)  then anim_frame = 10;
			if (attack_frame == 1)  then anim_frame = 11; // Retorno
			
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