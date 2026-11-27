function danny_frost_mines(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_danny_power1;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 22;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 19) then anim_frame = 1;
			if (attack_frame == 16) then anim_frame = 2;
			if (attack_frame == 13) then anim_frame = 3;
			if (attack_frame == 10) then anim_frame = 4;
			if (attack_frame == 3)  then anim_frame = 6;
			
			if (attack_frame == 7)
				{
				anim_frame = 5;
				
				var _slot = danny_mine_count();
				if (_slot < DANNY_MINE_MAX)
					{
					var _offsets_x = [130, 230, 330];
					var _offsets_y = [-30, -90, -30];
					
					var _hitbox = hitbox_create(_offsets_x[_slot], _offsets_y[_slot], 0.8, 0.8, 8, DANNY_MINE_LIFE);
					_hitbox.destroy_on_stop = true;
					_hitbox.custom_update = danny_mine_hitbox_update;
					_hitbox.custom_draw = danny_mine_hitbox_draw;
					_hitbox.knockback = 6;
					_hitbox.hitstun = 28;
					_hitbox.facing = facing;
					_hitbox.fatality = FATALITY.estallido;					
					}
				}
			
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