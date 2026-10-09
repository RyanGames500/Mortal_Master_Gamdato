function mariel_special_superkick(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mariel_special_superkick;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 16; // Carga visible: se nota que viene algo grande
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup: carga con parpadeo (frames 0 -> 5), impacto en el 6
		case 0:
			{
			attack_frame--;
			
			//Animación de carga
			if (attack_frame == 12) then anim_frame = 1; // rojo
			if (attack_frame == 10) then anim_frame = 2; // amarillo
			if (attack_frame == 8)  then anim_frame = 3; // rojo
			if (attack_frame == 6)  then anim_frame = 4; // amarillo
			if (attack_frame == 4)
				{
				anim_frame = 5; // Pierna lista
				
				//Silbido (solo sonido; se omite durante un rollback)
				if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_whoosh_heavy);
				}
			
			//Impacto: frame 6
			if (attack_frame <= 0)
				{
				anim_frame = 6;
				attack_phase = 1;
				attack_frame = 28;
				hsp = 10 * facing; // Arranque fuerte hacia adelante
				
				var _hitbox = hitbox_create(60, -20, 1.8, 1.1, 20, 6);
				_hitbox.grounded_only = true;  // Solo rivales en el suelo
				_hitbox.hitlag = 18;           // Congelado largo = golpe pesado
				_hitbox.knockback = 5;
				_hitbox.launch_speed = 30;     // Sale hacia arriba
				_hitbox.hitstun = 50;
				_hitbox.knockdown = true;
				}
			
			player_move();
			}
		break;
		
		//Active y endlag (frames 6 -> 8), por rangos para poder cortar el recovery
		case 1:
			{
			attack_frame--;
			
			//Si conectó, recupera más rápido
			if (attack_frame > 12 && attack_connected) then attack_frame = 12;
			
			if (attack_frame >= 22)      then anim_frame = 6; // Patada / pisotón
			else if (attack_frame >= 12) then anim_frame = 7;
			else                              anim_frame = 8;
			
			//Frenado escalonado del impulso (sin decimales)
			if (attack_frame > 25)       then hsp = 10 * facing;
			else if (attack_frame > 23)  then hsp = 6 * facing;
			else if (attack_frame > 21)  then hsp = 3 * facing;
			else                              hsp = 0;
			
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