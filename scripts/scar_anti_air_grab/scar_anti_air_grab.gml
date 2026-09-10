function scar_anti_air_grab(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = sprScar_Agarre2;
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
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 25;
				
				var _hitbox = hitbox_create(60, -90, 0.8, 0.8, 0, 5);
				_hitbox.grab = true;
				_hitbox.hitstun = 120;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 15) then anim_frame = 3;
			
			if (attack_connected)
				{
				anim_frame = 4;
				attack_phase = 2;
				attack_frame = 35;
				
				hitlag_frame = 8;
				
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
					_other_player.hitlag_frame = 8;
					}
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
			
			if (attack_frame == 28) then anim_frame = 5;
			if (attack_frame == 20) then anim_frame = 6;
			if (attack_frame == 12) then anim_frame = 7;
			if (attack_frame == 6)  then anim_frame = 8;
			if (attack_frame == 2)  then anim_frame = 9;
			
			if (_other_player != noone)
				{
				_other_player.hitstun = 60;
				_other_player.hsp = 0;
				_other_player.vsp = 0;
				
				if (!is_undefined(_other_player.sprites[$ "throw_2_hit"]))
					{
					_other_player.anim_sprite = _other_player.sprites[$ "throw_2_hit"];
					}
				
				if (anim_frame <= 4)
					{
					_other_player.anim_frame = 0;
					_other_player.x = x + (55 * facing);
					_other_player.y = y - 85;
					}
				else if (anim_frame == 5 || anim_frame == 6)
					{
					_other_player.anim_frame = 1;
					_other_player.x = x + (10 * facing);
					_other_player.y = y - 110;
					}
				else if (anim_frame == 7)
					{
					_other_player.anim_frame = 2;
					_other_player.x = x - (40 * facing);
					_other_player.y = y - 45;
					}
				else if (anim_frame >= 8)
					{
					_other_player.anim_frame = 3;
					_other_player.x = x - (75 * facing);
					_other_player.y = y;
					}
				}
			
			if (attack_frame == 6)
				{
				if (_other_player != noone)
					{
					with (_other_player)
						{
						player_damage(22);
						}
					hitlag_frame = 6;
					_other_player.hitlag_frame = 6;
					obj_game.cam_shake = 8;
					hit_sfx_play(snd_hit_heavy);
					}
				}
			
			if (attack_frame <= 0)
				{
				anim_frame = 10;
				attack_connected = false;
				
				attack_phase = 3;
				attack_frame = 15;
				}
			}
		break;
		
		case 3:
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
				if (!is_undefined(_other_player.sprites[$ "throw_2_hit"]))
					{
					_other_player.anim_sprite = _other_player.sprites[$ "throw_2_hit"];
					}
				_other_player.anim_frame = 4;
				_other_player.x = x - (75 * facing);
				_other_player.y = y;
				}
			
			if (attack_frame <= 0)
				{
				if (_other_player != noone)
					{
					with (_other_player)
						{
						player_state_set(PLAYER_STATE.knockdown);
						state_frame = 25;
						}
					}
				attack_stop();
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */