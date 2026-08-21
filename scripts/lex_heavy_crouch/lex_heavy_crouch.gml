function lex_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_heavy_crouch;
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
			
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 2;
			
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 28;
				hsp = 3 * facing;
				
				var _hitbox = hitbox_create(201, -10, 0.6, 0.3, 12, 80);
				_hitbox.sprite_index = spr_hitbox_square;
				_hitbox.hitlag = 12;
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 15;
				_hitbox.hitstun = 35;
				_hitbox.crouch = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 22) then anim_frame = 4;
			if (attack_frame == 15) then anim_frame = 5;
			if (attack_frame == 8)  then anim_frame = 6;
			
			if (attack_frame == 24)
				{
				hsp = 0;
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
/* Copyright 2024 Springroll Games / Yosi */