function lex_bomb_ex_spawn(_hsp, _vsp)
	{
	var _hitbox = hitbox_create(40, -90, 0.8, 0.8, 9, 100);
	_hitbox.destroy_on_stop = true;
	_hitbox.custom_update = lex_bomb_hitbox_update;
	_hitbox.custom_draw = lex_bomb_hitbox_draw;
	_hitbox.facing = facing;
	_hitbox.hsp = _hsp * facing;
	_hitbox.vsp = _vsp;
	_hitbox.hitstun = 28;
	_hitbox.hitlag = 8;
	_hitbox.knockback = 8;
	}

function lex_bomb_ex(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_bomb;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;		// startup mas rapido que el normal (6)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//--- Startup + bomba 1 (corta) ---
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 26;
				
				lex_bomb_ex_spawn(5, -4);
				}
			
			player_move();
			}
		break;
		
		//--- Bomba 2 (media) y bomba 3 (larga) ---
		case 1:
			{
			attack_frame--;
			
			ex_flash = max(ex_flash, 8);
			
			if (attack_frame == 20) then anim_frame = 1;
			if (attack_frame == 18)
				{
				anim_frame = 2;
				lex_bomb_ex_spawn(10, -6);
				obj_game.cam_shake = max(obj_game.cam_shake, 2);
				}
			
			if (attack_frame == 12) then anim_frame = 1;
			if (attack_frame == 10)
				{
				anim_frame = 2;
				lex_bomb_ex_spawn(14, -8);
				obj_game.cam_shake = max(obj_game.cam_shake, 3);
				}
			
			if (attack_frame == 6) then anim_frame = 3;
			if (attack_frame == 3) then anim_frame = 4;
			
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