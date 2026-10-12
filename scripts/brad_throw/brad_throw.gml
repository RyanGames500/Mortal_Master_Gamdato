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
					// Lanzamiento con arco: viaja de las manos al piso en pocos frames
					var _t = clamp((10 - attack_frame) / 3, 0, 1);
					_carry_x = lerp(0, 150, _t);
					_carry_y = lerp(0, -15, _t) - (sin(_t * pi) * 50);
					_victim_frame = 1;
					}
				
				if (!is_undefined(_carry_sprite))
					{
					_victim_frame = clamp(_victim_frame, 0, sprite_get_number(_carry_sprite) - 1);
					}
				
				_other_player.x = x + (_carry_x * facing);
				_other_player.y = y + _carry_y;
				_other_player.anim_frame = _victim_frame;
				}
			
			if (attack_frame == 21) then anim_frame = 8;
			if (attack_frame == 18) then anim_frame = 9;
			if (attack_frame == 15) then anim_frame = 10;
			if (attack_frame == 12) then anim_frame = 11;
			if (attack_frame == 9)
				{
				anim_frame = 12;
				// Temblor leve al lanzarlo
				obj_game.cam_shake = max(obj_game.cam_shake, 3);
				}
			
			// =========================================================================
			// REMATE: el hitbox derriba al rival (daño, combo, sonido, chispa y temblor)
			// =========================================================================
			if (attack_frame == 6)
				{
				anim_frame = 13;
				attack_connected = false;
				
				if (_other_player != noone)
					{
					// El rival ya no es "cargado": el hitbox lo manda a knockdown
					_other_player.being_carried = false;
					
					// Lo apoya en el piso
					_other_player.y = ceil(obj_ground.y - (_other_player.bbox_bottom - _other_player.y));
					
					// Polvo donde lo estrella
					var _land_vfx = instance_create_layer(_other_player.x, obj_ground.y, "VFX_Layer", obj_vfx);
					_land_vfx.sprite_index = spr_effect_landing_dust;
					_land_vfx.image_xscale = facing;
					_land_vfx.anim_speed   = 0.2;
					_land_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _land_vfx.anim_speed;
					_land_vfx.owner        = id;
					
					// Hitbox justo sobre el rival (desde su posicion real)
					var _hx = (_other_player.x - x) * facing;
					var _hy = _other_player.y - y;
					var _hitbox = hitbox_create(_hx, _hy, 1.3, 1.5, 20, 3);
					_hitbox.grab = false;
					_hitbox.knockback = 10;
					_hitbox.knockdown = true;
					_hitbox.launch_speed = 18;
					_hitbox.hitstun = 35;
					_hitbox.hitlag = 14;
					}
				
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