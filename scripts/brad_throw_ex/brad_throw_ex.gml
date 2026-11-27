function brad_throw_ex(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_throw1;
			anim_frame = 0;
			anim_speed = 0;
			attack_frame = 7;
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 5) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 2;
			
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 30;
				
				var _hitbox = hitbox_create(125, -47, 1.5, 0.5, 0, 5);
				_hitbox.grab = true;
				_hitbox.hitstun = 90;
				_hitbox.grounded_only = true;
				}
			
			player_move();
			}
		break;
		
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
				attack_frame = 56;
				
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
			
			if (_other_player != noone && attack_frame < 55 && _other_player.state != PLAYER_STATE.grabbed)
				{
				_other_player.being_carried = false;
				attack_connected = false;
				anim_frame = 13;
				attack_phase = 3;
				attack_frame = 20;
				break;
				}
			
			var _t = 0;
			var _in_down = false;
			var _down_n = 0;
			var _rise_p = -1;
			var _hits = [40, 26, 12];
			for (var i = 0; i < 3; i++)
				{
				var _h = _hits[i];
				if (attack_frame <= _h + 4 && attack_frame >= _h)
					{
					_t = (_h + 4 - attack_frame) / 4;
					_in_down = true;
					_down_n = attack_frame - _h;
					}
				else if (i < 2 && attack_frame < _h && attack_frame >= _h - 6)
					{
					_t = 1 - ((_h - attack_frame) / 6);
					}
				
				if (i < 2 && attack_frame < _h && attack_frame >= _h - 9)
					{
					_rise_p = (_h - 1 - attack_frame) / 8;
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
				
				var _carry_x = lerp(0, 130, _t);
				var _carry_y = lerp(0, -15, _t) - (sin(_t * pi) * 10);
				var _victim_frame = (_t > 0.3) ? 1 : 0;
				
				if (!is_undefined(_carry_sprite))
					{
					_victim_frame = clamp(_victim_frame, 0, sprite_get_number(_carry_sprite) - 1);
					}
				
				_other_player.x = x + (_carry_x * facing);
				_other_player.y = y + _carry_y;
				_other_player.anim_frame = _victim_frame;
				}
			
			if (attack_frame > 44)
				{
				if (attack_frame == 53) then anim_frame = 8;
				if (attack_frame == 50) then anim_frame = 9;
				if (attack_frame == 47) then anim_frame = 10;
				}
			else if (_in_down)
				{
				anim_frame = (_down_n >= 3) ? 11 : 12;
				}
			else if (_rise_p >= 0)
				{
				anim_frame = 7 + floor(clamp(_rise_p, 0, 1) * 3.99);
				}
			else
				{
				anim_frame = 10;
				}
			
			if (attack_frame == 40 || attack_frame == 26)
				{
				var _dmg = (attack_frame == 40) ? 6 : 8;
				
				if (_other_player != noone)
					{
					player_damage(_dmg, _other_player);
					with (_other_player)
						{
						combo_register_hit();
						}
					hit_sfx_play((attack_frame == 40) ? snd_hit_floor1 : snd_hit_floor2);
					
					_other_player.hitlag_frame = 5;
					hitlag_frame = 5;
					
					var _vfx = instance_create_layer(_other_player.x, obj_ground.y, "VFX_Layer", obj_vfx);
					_vfx.sprite_index = spr_effect_landing_dust;
					_vfx.image_xscale = facing;
					_vfx.anim_speed   = 0.2;
					_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _vfx.anim_speed;
					_vfx.owner        = id;
					
					if (_other_player.hp <= 0)
						{
						_other_player.being_carried = false;
						_other_player.y = ceil(obj_ground.y - (_other_player.bbox_bottom - _other_player.y));
						with (_other_player)
							{
							player_state_set(PLAYER_STATE.knockdown);
							anim_frame = 0;
							hsp = 10 * other.facing;
							vsp = -12;
							}
						attack_connected = false;
						anim_frame = 13;
						attack_phase = 3;
						attack_frame = 20;
						obj_game.cam_shake = max(obj_game.cam_shake, 8);
						break;
						}
					}
				
				obj_game.cam_shake = max(obj_game.cam_shake, 6);
				}
			
			if (attack_frame == 12)
				{
				anim_frame = 13;
				attack_connected = false;
				
				var _hx = 130;
				var _hy = -15;
				
				if (_other_player != noone)
					{
					_other_player.being_carried = false;
					_other_player.y = ceil(obj_ground.y - (_other_player.bbox_bottom - _other_player.y));
					
					with (_other_player)
						{
						player_face_opponent();
						}
					
					var _land_vfx = instance_create_layer(_other_player.x, obj_ground.y, "VFX_Layer", obj_vfx);
					_land_vfx.sprite_index = spr_effect_landing_dust;
					_land_vfx.image_xscale = facing;
					_land_vfx.anim_speed   = 0.2;
					_land_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _land_vfx.anim_speed;
					_land_vfx.owner        = id;
					
					_hx = (_other_player.x - x) * facing;
					_hy = _other_player.y - y;
					}
				
				var _fin = hitbox_create(_hx, _hy, 1.4, 1.5, 22, 3);
				_fin.grab = false;
				_fin.knockback = 12;
				_fin.knockdown = true;
				_fin.launch_speed = 20;
				_fin.hitstun = 40;
				_fin.hitlag = 16;
				
				obj_game.cam_shake = max(obj_game.cam_shake, 10);
				
				attack_phase = 3;
				attack_frame = 20;
				}
			}
		break;
		
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