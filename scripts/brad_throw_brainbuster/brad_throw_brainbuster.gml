function brad_throw_brainbuster(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_throw2;
			anim_frame = 0;
			anim_speed = 0;
			attack_frame = 6; // Startup más rápido
			hsp = 0;
			vsp = 0;
			jump_impulse_done = false;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 5) then anim_frame = 1;
			if (attack_frame == 3) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			
			if (attack_frame == 1)
				{
				anim_frame = 4;
				var _hitbox = hitbox_create(110, -45, 1.3, 0.5, 0, 4);
				_hitbox.grab = true;
				_hitbox.hitstun = 60;
				_hitbox.grounded_only = true;
				}
			
			if (attack_connected)
				{
				attack_phase = 1;
				attack_frame = 14; // Giro en tierra más rápido
				break;
				}
			
			player_move();
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 11) then anim_frame = 5;
			if (attack_frame == 8)  then anim_frame = 6;
			if (attack_frame == 5)  then anim_frame = 7;
			if (attack_frame == 2)  then anim_frame = 8;
			
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
				
				var _ground_sprite = _other_player.sprites[$ "hitstun_ground"];
				if (is_undefined(_ground_sprite))
					{
					_ground_sprite = _other_player.sprites[$ "hitstun_aerial"];
					}
				
				_other_player.anim_sprite = _ground_sprite;
				_other_player.anim_speed = 0;
				
				var _carry_x = 32;
				var _carry_y = 0;
				
				if (anim_frame <= 5)
					{
					_carry_x = 36;
					_carry_y = 0;
					_other_player.image_xscale = -facing;
					_other_player.anim_frame = 0;
					}
				else if (anim_frame == 6)
					{
					_carry_x = 12;
					_carry_y = 0;
					_other_player.image_xscale = facing;
					_other_player.anim_frame = 1;
					}
				else if (anim_frame >= 7)
					{
					_carry_x = -116;
					_carry_y = 0;
					_other_player.image_xscale = facing;
					_other_player.anim_frame = 1;
					}
				
				_other_player.x = x + (_carry_x * facing);
				_other_player.y = y + _carry_y;
				}
			
			player_move();
			
			if (attack_frame <= 0)
				{
				attack_phase = 2;
				attack_frame = 15;
				}
			}
		break;
		
		case 2:
			{
			var _other_player = noone;
			with (obj_player)
				{
				if (id != other.id)
					{
					_other_player = id;
					break;
					}
				}
			
			if (!jump_impulse_done)
				{
				anim_frame = 11;
				vsp = -30;
				hsp = 2 * facing;
				jump_impulse_done = true;
				}
			
			vsp += grav;
			player_move();
			
			if (vsp > 0)
				{
				anim_frame = 12;
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
					}
				
				_other_player.anim_sprite = _carry_sprite;
				_other_player.anim_speed = 0;
				_other_player.anim_frame = 0;
				
				_other_player.image_xscale = -facing;
				_other_player.x = x - (8 * facing);
				_other_player.y = y - 70;
				}
			
			if (bbox_bottom >= obj_ground.y && vsp >= 0)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				vsp = 0;
				hsp = 0;
				jump_impulse_done = false;
				
				attack_phase = 3;
				attack_frame = 6; // Azote más rápido en tierra
				}
			}
		break;
		
		//--- FASE 3: REMATE AL TOCAR EL SUELO ---
		case 3:
			{
			attack_frame--;
			anim_frame = 14;
			
			var _other_player = noone;
			with (obj_player)
				{
				if (id != other.id)
					{
					_other_player = id;
					break;
					}
				}
			
			// Momento exacto del azote (Sincronizado a la nueva velocidad)
			if (attack_frame == 5)
				{
				attack_connected = false;

				if (_other_player != noone)
					{
					_other_player.being_carried = false;
					_other_player.player_state_set(PLAYER_STATE.knockdown);
					
					_other_player.x = x + (45 * facing);
					_other_player.y = y;
					_other_player.image_xscale = facing;
					_other_player.hsp = 8 * facing;
					_other_player.vsp = -5;
					}

				var _hitbox = hitbox_create(183, 97, 1.8, 0.9, 35, 3);
				_hitbox.knockdown = true;
				_hitbox.grab = false;
				_hitbox.knockback = 15;
				_hitbox.launch_speed = 18
				_hitbox.hitstun = 50;
				
				obj_game.cam_shake = 8;
				}
			
			//player_move();
			
			if (attack_frame <= 0)
				{
				attack_phase = 4;
				attack_frame = 10; // Levantada rápida
				}
			}
		break;
		
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 16;
			if (attack_frame == 6) then anim_frame = 17;
			if (attack_frame == 4) then anim_frame = 18;
			if (attack_frame == 2) then anim_frame = 19;
			if (attack_frame == 1) then anim_frame = 20;
			
			hsp = 0;
			vsp = 0;
			
			player_move();
			
			if (attack_frame <= 0)
				{
				attack_stop();
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */