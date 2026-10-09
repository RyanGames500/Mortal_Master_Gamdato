function mariel_heavy_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mariel_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12; // Startup lento: carga pesada
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup (frames 0 -> 1 -> 2, impacto en 3)
		case 0:
			{
			attack_frame--;
			
			//Throws
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			//Animation
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 3)
				{
				anim_frame = 2;
				
				//Silbido del barrido (solo sonido; se omite durante un rollback)
				if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_whoosh_heavy);
				}
			
			//Hitbox: barrido extendido (frame 3)
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 34;
				hsp = 8 * facing;
				
				var _hitbox = hitbox_create(85, 124, 1.5, 0.35, 14, 12);
				_hitbox.low = true;
				_hitbox.hitlag = 7;          // congelado corto
				_hitbox.knockback = 12;
				_hitbox.knockdown = true;    // cae acostado
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Active and Endlag (frames 4 -> 10)
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 31) then anim_frame = 4;
			if (attack_frame == 28) then anim_frame = 5;
			if (attack_frame == 25) then anim_frame = 6; // Extensión máxima
			if (attack_frame == 20) then anim_frame = 7; // Empieza a levantarse
			if (attack_frame == 15) then anim_frame = 8;
			if (attack_frame == 10) then anim_frame = 9;
			if (attack_frame == 5)  then anim_frame = 10;
			
			//Movement: termina el deslizamiento
			if (attack_frame == 22)
				{
				hsp = 0;
				}
			player_move();
			
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