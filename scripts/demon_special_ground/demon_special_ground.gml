function demon_special_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_demon_especial1;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Preparacion (frames 0 a 2) y golpe (frame 3)
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 22;
				
				var _hitbox = hitbox_create(85, -35, 1.4, 0.6, 40, 8);
				_hitbox.hitlag = 10;
				_hitbox.launch_speed = 35;
				_hitbox.knockback = 15;
				_hitbox.high = true;
				_hitbox.knockdown = true;
				_hitbox.hitstun = 40;
				}
			
			player_move();
			}
		break;
		
		//Recuperacion (frames 4 a 7)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 20) then anim_frame = 4;
			if (attack_frame == 15) then anim_frame = 5;
			if (attack_frame == 10) then anim_frame = 6;
			if (attack_frame == 5)  then anim_frame = 7;
			
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