function lex_special_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_special_ground;
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 12;
			hsp = 1 * facing;
			vsp = 0;
			}
		break;

		// --- GOLPE 1: JAB RÁPIDO ---
		case 0:
			{
			attack_frame--;

			if (attack_frame == 10) then anim_frame = 1;
			if (attack_frame == 8)  then anim_frame = 2;
			if (attack_frame == 6)  then anim_frame = 3;
			if (attack_frame == 4)  then anim_frame = 4;

			if (attack_frame == 6)
				{
				var _hitbox = hitbox_create(92, -70, 1.2, 0.6, 10, 3);
				_hitbox.knockback = 2;
				}

			if (attack_frame <= 0)
				{
				attack_connected = false; // RESET DE COLISIÓN ESTILO BLOCKY
				
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 16;
				hsp = 2 * facing;
				}

			player_move();
			}
		break;

		// --- GOLPE 2: RECTO DE DERECHA ---
		case 1:
			{
			attack_frame--;

			if (attack_frame == 14) then anim_frame = 6;
			if (attack_frame == 11) then anim_frame = 7;
			if (attack_frame == 8)  then anim_frame = 8;
			if (attack_frame == 5)  then anim_frame = 9;
			if (attack_frame == 2)  then anim_frame = 10;

			if (attack_frame == 8)
				{
				var _hitbox = hitbox_create(80, -33, 1.4, 0.6, 10, 4);
				_hitbox.knockback = 3;
				}

			if (attack_frame <= 0)
				{
				attack_connected = false; // RESET DE COLISIÓN ESTILO BLOCKY
				
				anim_frame = 11;
				attack_phase = 2;
				attack_frame = 18;
				hsp = 2.5 * facing;
				}

			player_move();
			}
		break;

		// --- GOLPE 3: GIRO DE CODO ---
		case 2:
			{
			attack_frame--;

			if (attack_frame == 15) then anim_frame = 12;
			if (attack_frame == 12) then anim_frame = 13;
			if (attack_frame == 9)  then anim_frame = 14;
			if (attack_frame == 6)  then anim_frame = 15;

			if (attack_frame == 9)
				{
				var _hitbox = hitbox_create(91, -59, 0.8, 0.9, 10, 5);
				_hitbox.knockback = 3;
				}

			if (attack_frame <= 0)
				{
				attack_connected = false; // RESET DE COLISIÓN ESTILO BLOCKY
				
				anim_frame = 16;
				attack_phase = 3;
				attack_frame = 24;
				hsp = 4 * facing;
				}

			player_move();
			}
		break;

		// --- GOLPE 4: REMATE FINAL ---
		case 3:
			{
			attack_frame--;

			if (attack_frame == 20) then anim_frame = 17;
			if (attack_frame == 16) then anim_frame = 18;
			if (attack_frame == 12) then anim_frame = 19;
			if (attack_frame == 8)  then anim_frame = 20;
			if (attack_frame == 5)  then anim_frame = 21;
			if (attack_frame == 2)  then anim_frame = 22;

			if (attack_frame == 16)
				{
				var _hitbox = hitbox_create(63, -45, 1, 0.9, 10, 8);
				// --- AJUSTES DE REMATE VIOLENTO ---
				_hitbox.knockback = 3;       // Empuje base alto
				_hitbox.launch_speed = 30;    // Impulso de salida violento
				_hitbox.hitstun = 40;         // Mantiene al rival incapacitado durante el vuelo
				_hitbox.hitlag = 6;
				}

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