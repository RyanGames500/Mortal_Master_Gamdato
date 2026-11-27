function lex_throw(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blocky_throw;
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
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 30;
				
				var _hitbox = hitbox_create(82, 6, 0.5, 0.7, 0, 5);
				_hitbox.grab = true;
				_hitbox.hitstun = 60;
				_hitbox.grounded_only = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 26) then anim_frame = 2;
			if (attack_frame == 13) then anim_frame = 3;
			
			if (attack_connected)
				{
				anim_frame = 4;
				attack_phase = 2;
				attack_frame = 40;
				
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
			_other_player.x = x + (4 * facing);
			_other_player.y = y + 62;
			
			if (attack_frame % 4 == 0)
				{
				if (anim_frame < 14) then anim_frame++;
				}
			if (attack_frame % 6 == 0)
				{
				player_damage(1, _other_player);
				hitlag_frame = 3;
				_other_player.hitlag_frame = 3;
				obj_game.cam_shake = 2;
				}
			
			if (attack_frame == 0)
				{
				attack_connected = false;
				_other_player.y = ceil(obj_ground.y - (_other_player.bbox_bottom - _other_player.y));
				var _hitbox = hitbox_create(11, -8, 0.8, 1.5, 15, 4);
				_hitbox.knockback = 15;
				_hitbox.launch_speed = 15;
				attack_phase = 3;
				attack_frame = 20;
				}
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 15;
			if (attack_frame == 10) then anim_frame = 16;
			if (attack_frame == 5) then anim_frame = 17;
			
			if (attack_frame == 0)
				{
				attack_stop();
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */