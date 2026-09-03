function saori_light_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 14;
				
				var _hitbox = hitbox_create(67, -65, 0.9, 0.2, 5, 5);
				_hitbox.knockback = 2;
				_hitbox.hitstun = 20;
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
			
			if (attack_frame == 10) then anim_frame = 2;
			if (attack_frame == 6)  then anim_frame = 3;
			if (attack_frame == 3)  then anim_frame = 4;
			
			// CANCELACIÓN AÉREA: Si presiona el botón durante la ventana activa del golpe
			if (attack_frame <= 12)
				{
				if (input_pressed(INPUT.attack_light2))
					{
					attack_stop();
					attack_start(attacks[$ "medium_aerial"]);
					break;
					}
				if (input_pressed(INPUT.attack_heavy))
					{
					attack_stop();
					attack_start(attacks[$ "heavy_aerial"]);
					break;
					}
				}

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