function blocky_runpunch_ex(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blocky_runpunch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 2)
				{
				anim_frame = 1;
				}
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 24;
				
				hsp = 20 * facing;
				vsp = -2;
				
				// polvo y temblor en el despegue
				var _dust = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_dust.sprite_index = spr_effect_step_dust;
				_dust.image_xscale = facing;
				_dust.anim_speed   = 0.2;
				_dust.lifetime     = sprite_get_number(spr_effect_step_dust) / _dust.anim_speed;
				_dust.owner        = id;
				obj_game.cam_shake = max(obj_game.cam_shake, 4);
				
				var _hitbox = hitbox_create(205, -1, 1.6, 0.8, 18, 18);
				_hitbox.hitlag = 14;
				_hitbox.launch_speed = 16;
				_hitbox.high = true;
				_hitbox.knockback = 22;
				_hitbox.knockdown = true;
				_hitbox.hitstun = 40;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 14) then anim_frame = 4;
			if (attack_frame == 8)  then anim_frame = 5;
			
			hsp = lerp(hsp, 0, 0.05);
			
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