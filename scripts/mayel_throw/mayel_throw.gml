function mayel_throw(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_grab;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 24;
				
				var _hitbox = hitbox_create(45, -30, 1, 0.6, 0, 4);
				_hitbox.grab = true;
				_hitbox.hitstun = 55;
				_hitbox.grounded_only = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 3;
			
			if (attack_connected)
				{
				anim_frame = 4;
				attack_phase = 2;
				attack_frame = 30;
				
				with (obj_player)
					{
					if (id != other.id)
						{
						player_state_set(PLAYER_STATE.grabbed);
						state_frame = 50;       
						being_carried = true;   
						
						var _vs = sprites[$ "throw_victim"];
						if (is_undefined(_vs)) then _vs = sprites[$ "hitstun_ground"];
						anim_sprite = _vs;
						anim_speed = 0;
						anim_frame = 0;
						break;
						}
					}
				
				if (stick_check_direction(STICK_DIR.backward_any))
					{
					facing *= -1;
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
			
			var _launch_frame = 2;
			
			var _anim = [2, 3, 4, 5, 6];
			var _rx   = [20, 14, 0, -14, -20]; 
			var _ry   = [0, -26, -50, -26, 0]; 
			var _vf   = [0, 1, 2, 3, 4];       
			var _move = [0, 0, 1, 1, 0];
			
			if (attack_frame > _launch_frame)
				{
				var _step = clamp(floor((29 - attack_frame) / 6), 0, 4);
				anim_frame = _anim[_step];
				if (_move[_step]) then x += 5 * facing;
				
				if (_other_player != noone)
					{
					_other_player.hsp = 0;
					_other_player.vsp = 0;
					_other_player.anim_speed = 0;
					_other_player.x = x + _rx[_step] * facing;
					_other_player.y = y + _ry[_step];
					
					var _vmax = sprite_get_number(_other_player.anim_sprite) - 1;
					_other_player.anim_frame = min(_vf[_step], _vmax);
					}
				}
			
			if (attack_frame == _launch_frame)
				{
				attack_connected = false;
				
				if (_other_player != noone)
					{
					var _throw_dir = sign(_other_player.x - x);
					if (_throw_dir == 0) then _throw_dir = facing;
					
					facing = -_throw_dir;
					
					with (_other_player)
						{
						being_carried = false;
						y = ceil(obj_ground.y - (bbox_bottom - y));
						
						facing = _throw_dir;
						
						player_state_set(PLAYER_STATE.hitstun_aerial);
						state_frame = 30;
						hitlag_frame = 10;
						
						hsp = 20 * _throw_dir;
						vsp = -15;
						}
					
					player_damage(14, _other_player);
					hitlag_frame = 10;
					obj_game.cam_shake = 6;
					}
				
				attack_phase = 3;
				attack_frame = 12 + _launch_frame;
				}
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 8;
			
			if (attack_frame == 0)
				{
				attack_stop();
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */