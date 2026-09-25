function brad_throw(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_throw1;
			anim_frame = 0;
			anim_speed = 0;
			attack_frame = 9;
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//--- STARTUP: Frames 0 -> 3 ---
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 1;
			if (attack_frame == 3) then anim_frame = 2;
			
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 30;
				
				var _hitbox = hitbox_create(115, -47, 1.3, 0.5, 0, 5);
				_hitbox.grab = true;
				_hitbox.hitstun = 60;
				_hitbox.grounded_only = true;
				}
			
			player_move();
			}
		break;
		
		//--- SUJECIÓN INICIAL: Frames 4, 5, 6 ---
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 26) then anim_frame = 4;
			if (attack_frame == 18) then anim_frame = 5;
			if (attack_frame == 10) then anim_frame = 6;
			
			if (attack_connected)
				{
				anim_frame = 7;
				attack_phase = 2;
				attack_frame = 24; // Duración exacta de la carga
				
				var _other_player = noone;
				with (obj_player)
					{
					if (id != other.id)
						{
						_other_player = id;
						break;
						}
					}
				
				if (_other_player != noone)
					{
					_other_player.being_carried = true;
					}
				
				if (stick_check_direction(STICK_DIR.backward_any))
					{
					facing *= -1;
					x += -20 * facing;
					}
				break;
				}
			
			player_move();
			
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
//--- ALZAMIENTO Y CARGA ---
		case 2:
			{
			attack_frame--;
			
			var _other_player = noone;
			with (obj_player)
				{
				if (id != other.id)
					{
					_other_player = id;
					break;
					}
				}
			
			if (_other_player != noone)
				{
				_other_player.state = PLAYER_STATE.grabbed;
				_other_player.being_carried = true;
				_other_player.hsp = 0;
				_other_player.vsp = 0;
				
				var _carry_sprite = _other_player.sprites[$ "grabbed_carry"];
				if (is_undefined(_carry_sprite))
					{
					_carry_sprite = _other_player.sprites[$ "hitstun_aerial"];
					if (is_undefined(_carry_sprite))
						{
						_carry_sprite = _other_player.sprites[$ "hitstun"];
						}
					}
				
				_other_player.anim_sprite = _carry_sprite;
				_other_player.anim_speed = 0;
				_other_player.image_xscale = facing;
				
				var _carry_x = 10;
				var _carry_y = -20;
				var _victim_frame = 0;
				
				if (anim_frame >= 8 && anim_frame <= 11)
					{
					_carry_x = 0;
					_carry_y = 0;
					_victim_frame = 0;
					}
				else if (anim_frame >= 12)
					{
					_carry_x = 150;
					_carry_y = -15;
					_victim_frame = 1;
					}
				
				_other_player.x = x + (_carry_x * facing);
				_other_player.y = y + _carry_y;
				_other_player.anim_frame = _victim_frame;
				}
			
			if (attack_frame == 21) then anim_frame = 8;
			if (attack_frame == 18) then anim_frame = 9;
			if (attack_frame == 15) then anim_frame = 10;
			if (attack_frame == 12) then anim_frame = 11;
			if (attack_frame == 9)  then anim_frame = 12;
			
			// =========================================================================
			// AQUÍ VA TU BLOQUE: REMATE, HITBOX Y TRANSICIÓN A KNOCKDOWN
			// =========================================================================
			if (attack_frame == 6)
				{
				anim_frame = 13;
				attack_connected = false;

				if (_other_player != noone)
					{
					_other_player.being_carried = false;
					
					// ENVIAR AL ENEMIGO A KNOCKDOWN
					_other_player.player_state_set(PLAYER_STATE.knockdown);
					
					// Impulso del golpe final al tocar el piso
					_other_player.hsp = 8 * facing;
					_other_player.vsp = -5; // Un pequeño rebote en el suelo
					}

				// Hitbox de remate para registrar daño
				var _hitbox = hitbox_create(152, 110, 1.3, 0.2, 20, 3);
				_hitbox.grab = false;
				_hitbox.knockback = 10;
				_hitbox.launch_speed = 18;
				_hitbox.hitstun = 35;
				
				attack_phase = 3;
				attack_frame = 20;
				}
			}
		break;
		
		//--- ENDLAG ---
		case 3:
			{
			attack_frame--;
			anim_frame = 13;
			
			if (attack_frame == 0)
				{
				attack_stop();
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */