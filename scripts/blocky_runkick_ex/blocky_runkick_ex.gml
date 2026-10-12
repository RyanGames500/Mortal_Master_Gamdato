function blocky_runkick_ex(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blocky_runkick;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 3;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 28;
				hsp = 24 * facing;
				
				// polvo y temblor en el despegue
				var _dust = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_dust.sprite_index = spr_effect_step_dust;
				_dust.image_xscale = facing;
				_dust.anim_speed   = 0.2;
				_dust.lifetime     = sprite_get_number(spr_effect_step_dust) / _dust.anim_speed;
				_dust.owner        = id;
				obj_game.cam_shake = max(obj_game.cam_shake, 4);
				
				// primera patada (no tira al piso para poder enlazar la segunda)
				var _hitbox = hitbox_create(95, 18, 0.8, 1, 12, 15);
				_hitbox.hitlag = 10;
				_hitbox.launch_speed = 6;
				_hitbox.high = true;
				_hitbox.knockback = 8;
				_hitbox.hitstun = 28;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 24) then anim_frame = 2;
			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 15) then anim_frame = 4;
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 5)  then anim_frame = 6;
			
			// segunda patada si la primera conecto
			if (attack_frame == 14 && attack_connected)
				{
				attack_connected = false;
				
				var _hitbox2 = hitbox_create(100, 18, 1, 1.2, 14, 8);
				_hitbox2.hitlag = 13;
				_hitbox2.launch_speed = 14;
				_hitbox2.high = true;
				_hitbox2.knockback = 20;
				_hitbox2.knockdown = true;
				_hitbox2.hitstun = 40;
				obj_game.cam_shake = max(obj_game.cam_shake, 7);
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