function demon_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_demon_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 11;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Preparacion (frames 0 a 3) y golpe (frame 4)
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 5) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			
			if (attack_frame == 0)
				{
				anim_frame = 4;
				attack_phase = 1;
				attack_frame = 17;
				hsp = 0;
				
				var _hitbox = hitbox_create(70, -10, 2.5, 2.5, 35, 6);
				_hitbox.sprite_index = spr_hitbox_circle;
				_hitbox.acid_finisher = true;
				_hitbox.hitlag = 13;
				_hitbox.knockback = 25;
				_hitbox.knockdown = true;
				_hitbox.launch_speed = 35;
				_hitbox.hitstun = 50;
				}
			
			player_move();
			}
		break;
		
		//Recuperacion (frames 5 a 8)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 5;
			if (attack_frame == 10) then anim_frame = 6;
			if (attack_frame == 6)  then anim_frame = 7;
			if (attack_frame == 2)  then anim_frame = 8;
			
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