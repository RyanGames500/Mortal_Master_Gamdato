function mayel_volando(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_fly;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 7;
			attack_connected = false;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
			
			if (attack_frame == 0)
				{
				attack_phase = 1;
				attack_frame = 22;
				hsp = 18 * facing;
				vsp = 5;
				
				var _hitbox = hitbox_create(60, 0, 1.4, 0.8, 11, 22);
				_hitbox.hitlag = 9;
				_hitbox.hitstun = 38;
				_hitbox.launch_speed = 13;
				_hitbox.knockback = 5;
				_hitbox.high = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			anim_frame = (attack_frame div 2) mod 4;
			
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				hsp = 0;
				vsp = 0;
				attack_phase = 2;
				attack_frame = attack_connected ? 8 : 14;
				break;
				}
			
			if (attack_connected)
				{
				var _blocked = false;
				with (obj_player)
					{
					if (id != other.id && state == PLAYER_STATE.blockstun) then _blocked = true;
					}
				hsp = 0;
				vsp = 0;
				attack_phase = 2;
				attack_frame = _blocked ? 24 : 10;
				break;
				}
			
			if (attack_frame <= 0)
				{
				hsp = 0;
				vsp = 0;
				attack_phase = 2;
				attack_frame = 26;
				break;
				}
			}
		break;
		
		case 2:
			{
			attack_frame--;
			anim_frame = 0;
			
			if (bbox_bottom < obj_ground.y)
				{
				vsp += grav;
				}
			player_move();
			if (vsp > 0 && bbox_bottom >= obj_ground.y)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				vsp = 0;
				}
			
			if (attack_connected && attack_frame <= 8 && bbox_bottom < obj_ground.y)
				{
				var _blocking = false;
				with (obj_player)
					{
					if (id != other.id && state == PLAYER_STATE.blockstun) then _blocking = true;
					}
				if (!_blocking)
					{
					if (input_pressed(INPUT.attack_light))
						{
						attack_connected = false;
						attack_start(attacks[$ "light_aerial"]);
						return;
						}
					if (input_pressed(INPUT.attack_light2))
						{
						attack_connected = false;
						attack_start(attacks[$ "medium_aerial"]);
						return;
						}
					if (input_pressed(INPUT.attack_heavy))
						{
						attack_connected = false;
						attack_start(attacks[$ "heavy_aerial"]);
						return;
						}
					}
				}
			
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