function bear_fire_breath(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_bear_fireball;	// tu hoja del oso (7 cuadros)
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 24;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup: mano en la boca (cuadros 0 y 1)
		case 0:
			{
			attack_frame--;
			
			// Throws (este ataque se lanza con ligero, así que el agarre usa el fuerte)
			if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 12) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 44;
				}
			
			player_move();
			}
		break;
		
		//Active: 3 bolas de fuego (cuadros 2 -> 6)
		case 1:
			{
			attack_frame--;
			
			//Shots
			var _shot = -1;
			if (attack_frame == 36) then _shot = 0;
			if (attack_frame == 27) then _shot = 1;
			if (attack_frame == 18) then _shot = 2;
			
			if (_shot >= 0)
				{
				anim_frame = 3 + _shot;
				
				//Corta, media y lejana
				var _speeds = [5, 8, 11];
				var _lifts = [-9, -10, -11];
				
				//Boca: píxel de la hoja corregido por el origen real y la escala
				var _x_off = (47 - sprite_get_xoffset(anim_sprite)) * sprite_scale;
				var _y_off = (12 - sprite_get_yoffset(anim_sprite)) * sprite_scale;
				
				var _hitbox = hitbox_create(_x_off, _y_off, 0.55, 0.55, 12, 200);
				_hitbox.sprite_index = spr_hitbox_circle;
				_hitbox.destroy_on_stop = true;
				_hitbox.custom_update = bear_fire_hitbox_update;
				_hitbox.custom_draw = bear_fire_hitbox_draw;
				_hitbox.knockback = 14;
				_hitbox.hsp = _speeds[_shot] * facing;
				_hitbox.vsp = _lifts[_shot];
				_hitbox.facing = facing;
				boss_hit_weight(_hitbox, 2);
				}
			
			if (attack_frame == 10) then anim_frame = 6;
			
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