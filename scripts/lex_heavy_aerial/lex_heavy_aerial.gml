function lex_heavy_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 8;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 22;
				
				var _hitbox = hitbox_create(85, 17, 0.6, 0.5, 14, 25);
				_hitbox.knockback = 18;
				_hitbox.hitlag = 12;
				_hitbox.hitstun = 24;
				_hitbox.launch_speed = 8;
				_hitbox.high = true;
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
			
			if (attack_frame == 10) then anim_frame = 3;
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
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