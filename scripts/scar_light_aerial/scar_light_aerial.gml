function scar_light_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			// Startup: 4 frames para alzar la espada (subimágenes 0 y 1)
			attack_frame = 4;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 1;
			
			// Instante del tajo
			if (attack_frame <= 0)
				{
				anim_frame = 2; // Frame 2: Tajo descendente con llamas
				attack_phase = 1;
				attack_frame = 14;
				
				// Hitbox aérea
				var _hitbox = hitbox_create(146, -5, 1, 1.9, 5, 5);
				_hitbox.knockback = 2;
				_hitbox.hitstun = 16;
				_hitbox.blockstun = 12;
				_hitbox.hitlag = 6;
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
			
			// Recorrido de disipación de llamas (frames 3, 4 y 5)
			if (attack_frame == 10) then anim_frame = 3;
			if (attack_frame == 6)  then anim_frame = 4;
			if (attack_frame == 2)  then anim_frame = 5;
			

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
/* Copyright 2024 Springroll Games / Yosi */