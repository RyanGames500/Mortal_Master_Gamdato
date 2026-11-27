function mayel_hammer(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_lanza_martillo;
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 12;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			if (attack_frame == 8) then anim_frame = 1;
			
			if (attack_frame == 4) 
				{
				anim_frame = 3; 
				attack_phase = 1;
				attack_frame = 16;

				var _exists = false;
				with (obj_hitbox)
					{
					if (owner == other.id && custom_update == mayel_hammer_hitbox_update)
						{
						_exists = true;
						break;
						}
					}
				if (!_exists)
					{
					var _hitbox = hitbox_create(126, 33, 0.8, 0.8, 12, 100);
					_hitbox.destroy_on_stop = true;
					_hitbox.custom_update = mayel_hammer_hitbox_update;
					_hitbox.custom_draw = mayel_hammer_hitbox_draw;
					_hitbox.facing = facing;
					
					_hitbox.vsp = -15;
					_hitbox.hsp = 5 * facing;


					}
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			if (attack_frame == 11) then anim_frame = 3;
			if (attack_frame == 6)  then anim_frame = 4;
			if (attack_frame == 2)  then anim_frame = 5;

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