function mariel_special_super(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mariel_special_super;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 20;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Pose: frames 0 -> 5
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 17) then anim_frame = 1;
			if (attack_frame == 13) then anim_frame = 2;
			if (attack_frame == 9)  then anim_frame = 3;
			if (attack_frame == 5)  then anim_frame = 4;
			if (attack_frame == 2)  then anim_frame = 5;
			
			if (attack_frame <= 0)
				{
				anim_frame = 6;
				attack_phase = 1;
				attack_frame = 28;
				}
			
			player_move();
			}
		break;
		
		//Aura: frames 6 -> 12
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 24) then anim_frame = 7;
			if (attack_frame == 20) then anim_frame = 8;
			if (attack_frame == 16) then anim_frame = 9;
			if (attack_frame == 12) then anim_frame = 10;
			if (attack_frame == 8)  then anim_frame = 11;
			if (attack_frame == 4)  then anim_frame = 12;
			
			if (attack_frame <= 0)
				{
				anim_frame = 13;
				attack_phase = 2;
				attack_frame = 6;
				hsp = 8 * facing;
				rage_frames = 180; // Rage corto garantizado: 3 s (se amplía si conecta)
				}
			
			player_move();
			}
		break;
		
		//Embestida y golpe: frames 13 -> 14
		case 2:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 14;
				attack_phase = 3;
				attack_frame = 22;
				
				var _hitbox = hitbox_create(75, -55, 1.6, 1.0, 18, 4);
				_hitbox.hitlag = 12;
				_hitbox.knockback = 16;
				_hitbox.launch_speed = 18;
				_hitbox.knockdown = true;
				}
			
			player_move();
			}
		break;
		
		//Endlag: frames 15 -> 17
		case 3:
			{
			attack_frame--;
			
			//Premio si conectó: rage largo (10 s) y recupera más rápido
			if (attack_connected)
				{
				if (rage_frames < 600) then rage_frames = 600;
				if (attack_frame > 10) then attack_frame = 10;
				}
			
			if (attack_frame >= 17)      then anim_frame = 15;
			else if (attack_frame >= 10) then anim_frame = 16;
			else                              anim_frame = 17;
			
			if (attack_frame <= 14) then hsp = 0;
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