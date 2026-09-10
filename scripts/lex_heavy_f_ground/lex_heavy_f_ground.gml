function lex_heavy_f_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_heavy_f_ground; // Nombre de tu nueva tira de 10 frames
			anim_frame = 0;
			anim_speed = 0;

			// Startup: 9 frames para preparar el salto con rodilla
			attack_frame = 9;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			// Transición de carga antes de elevar la rodilla
			if (attack_frame == 6) then anim_frame = 1;
			if (attack_frame == 3) then anim_frame = 2;

			// Instante del golpe (Active Frame)
			if (attack_frame <= 0)
				{
				anim_frame = 3; // Frame 3: Impacto del rodillazo con destello
				attack_phase = 1;
				attack_frame = 24; // Tiempo total de recuperación (Recovery)

				// Impulso hacia adelante para dar buen alcance al rodillazo
				hsp = 4 * facing;

				// Crear Hitbox
				var _hitbox = hitbox_create(58, 36, 0.5, 1, 13, 5);
				_hitbox.sprite_index = spr_hitbox_square;
				_hitbox.hitlag = 12;
				_hitbox.knockback = 15;
				_hitbox.launch_speed = 13;
				_hitbox.hitstun = 36;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			// Frenar la inercia del movimiento progresivamente
			hsp = lerp(hsp, 0, 0.15);

			// Recorrido de caída y aterrizaje (subimágenes 4 a 9)
			if (attack_frame == 20) then anim_frame = 4;
			if (attack_frame == 16) then anim_frame = 5;
			if (attack_frame == 12) then anim_frame = 6;
			if (attack_frame == 8)  then anim_frame = 7;
			if (attack_frame == 4)  then anim_frame = 8;
			if (attack_frame == 1)  then anim_frame = 9; // Postura final en tierra

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