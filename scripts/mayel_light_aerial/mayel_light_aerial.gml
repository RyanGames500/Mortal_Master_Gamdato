function mayel_light_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
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
				
				var _hitbox = hitbox_create(42, 37, 0.6, 0.3, 5, 2);
				_hitbox.image_angle = -33 * facing;
				_hitbox.high = true;
				_hitbox.knockback = 3;
				_hitbox.hitstun = 30;
				}
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 20) then anim_frame = 2;
			if (attack_frame == 10) then anim_frame = 3;
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				if (attack_connected)
					{
					attack_stop();
					}
				else
					{
					hsp = 0;
					vsp = 0;
					anim_frame = 3;
					attack_phase = 2;
					attack_frame = 8;
					}
				break;
				}
			
			if (attack_connected && attack_frame < 24)
				{
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
			
			hsp = 0;
			vsp = 0;
			player_move();
			
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