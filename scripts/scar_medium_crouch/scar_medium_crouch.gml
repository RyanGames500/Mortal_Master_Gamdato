function scar_medium_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_medium_crouch; // Tira de 8 subimágenes (0 a 7)
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6; // Startup para dar peso al tajo agachado
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			// Animación de preparación
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 2; // Inicio del barrido
			
			// Instante del golpe (Subimagen 3: Extensión máxima)
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 18;
				
				// Deslizamiento bajo característico de Scar
				hsp = 4 * facing;
				
				// Hitbox a nivel del suelo marcada como LOW
				var _hitbox = hitbox_create(143, -14, 1.2, 1.7, 7, 4);
				_hitbox.acid_finisher = true;
				_hitbox.knockback = 6;
				_hitbox.low = true; // Solo se puede bloquear agachado
				_hitbox.hitstun = 26;
				_hitbox.blockstun = 18;
				_hitbox.hitlag = 8;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			// Frenar el deslizamiento
			hsp = lerp(hsp, 0, 0.2);

			// Recorrido fluido de la recolección y chispas (4 al 7)
			if (attack_frame == 14) then anim_frame = 4; // Estela de chispas
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 6)  then anim_frame = 6;
			if (attack_frame == 2)  then anim_frame = 7; // Retorno a postura agachada
			
			player_move();
			
			// CANCELACIÓN EN HIT: derivar a Heavy Crouch (Barredora pesada / Launcher)
			if (attack_connected)
				{
				if (input_pressed(INPUT.attack_heavy))
					{
					attack_stop();
					attack_start(attacks[$ "heavy_crouch"]);
					break;
					}
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
/* Copyright 2024 Springroll Games / Yosi */