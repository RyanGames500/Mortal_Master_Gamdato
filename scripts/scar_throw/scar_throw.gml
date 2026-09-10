function scar_throw(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_special1_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 30;
				
				var _hitbox = hitbox_create(98, -47, 1, 0.5, 0, 5);
				_hitbox.grab = true;
				_hitbox.hitstun = 120;
				_hitbox.grounded_only = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 26) then anim_frame = 4;
			if (attack_frame == 13) then anim_frame = 5;
			
			if (attack_connected)
				{
				anim_frame = 6;
				attack_phase = 2;
				attack_frame = 80;
				
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
			
			if (_other_player != noone)
				{
				_other_player.x = x + (105 * facing);
				_other_player.y = y - 28;
				}
			
			if (attack_frame == 74) then anim_frame = 7;
			if (attack_frame == 68) then anim_frame = 8;
			
			if (attack_frame == 62)
				{
				anim_frame = 11;
				if (_other_player != noone)
					{
					player_damage(10, _other_player);
					_other_player.hitstun = 60;
					hitlag_frame = 5;
					_other_player.hitlag_frame = 5;
					obj_game.cam_shake = 3;				
					hit_sfx_play(snd_hit_light_3);
					}
				}
			
			if (attack_frame == 54) then anim_frame = 13;
			if (attack_frame == 48) then anim_frame = 14;
			
			if (attack_frame == 42)
				{
				anim_frame = 16;
				if (_other_player != noone)
					{
					player_damage(10, _other_player);
					_other_player.hitstun = 60;
					hitlag_frame = 5;
					_other_player.hitlag_frame = 5;
					obj_game.cam_shake = 3;
					hit_sfx_play(snd_hit_light_3);
					}
				}
			
			if (attack_frame == 34) then anim_frame = 18;
			if (attack_frame == 28) then anim_frame = 19;
			
			if (attack_frame == 22)
				{
				anim_frame = 21;
				if (_other_player != noone)
					{
					player_damage(10, _other_player);
					_other_player.hitstun = 60;
					hitlag_frame = 5;
					_other_player.hitlag_frame = 5;
					obj_game.cam_shake = 3;
					hit_sfx_play(snd_hit_light_3);
					}
				}

			if (attack_frame == 16) then anim_frame = 23;
			if (attack_frame == 10) then anim_frame = 25;
			
			if (attack_frame == 0)
				{
				anim_frame = 27;
				attack_connected = false;
				
				var _hitbox = hitbox_create(85, -35, 1.0, 1.0, 15, 5);
				_hitbox.knockback = 18;
				_hitbox.launch_speed = 10;
				
				attack_phase = 3;
				attack_frame = 20;
				}
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 29;
			if (attack_frame == 12) then anim_frame = 30;
			if (attack_frame == 8)  then anim_frame = 31;
			if (attack_frame == 4)  then anim_frame = 32;
			
			if (attack_frame == 0)
				{
				attack_stop();
				}
			}
		break;
		}
	}