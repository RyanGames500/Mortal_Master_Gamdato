function danny_frost_ball(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_danny_power1;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 18;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 15) then anim_frame = 1;
			if (attack_frame == 12) then anim_frame = 2;
			if (attack_frame == 8)  then anim_frame = 3;
			if (attack_frame == 4)  then anim_frame = 4;
			
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 22;
				
				var _exists = false;
				with (obj_hitbox)
					{
					if (owner == other.id && custom_update == danny_frost_ball_hitbox_update)
						{
						_exists = true;
						break;
						}
					}
				if (!_exists)
					{
					var _hitbox = hitbox_create(95, -35, 0.6, 0.6, 12, 120);
					_hitbox.destroy_on_stop = true;
					_hitbox.custom_update = danny_frost_ball_hitbox_update;
					_hitbox.custom_draw = danny_frost_ball_hitbox_draw;
					_hitbox.knockback = 10;
					_hitbox.hitstun = 28;
					_hitbox.hsp = 4 * facing;
					_hitbox.fatality = FATALITY.mutar;					
					_hitbox.facing = facing;
					}
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 6;
			
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