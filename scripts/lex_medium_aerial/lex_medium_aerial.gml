function lex_medium_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_medium_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 16;
				
				var _hitbox = hitbox_create(94, 70, 0.7, 0.6, 6, 6);
				_hitbox.knockback = 15;
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
			
			if (attack_frame == 8) then anim_frame = 2;
			
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