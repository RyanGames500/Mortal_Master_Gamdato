function brad_roll_ex(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_roll_ini;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 2;
			if (attack_frame == 1) then anim_frame = 3;
			
			if (attack_frame == 0)
				{
				anim_sprite = spr_brad_Roll;
				anim_frame = 0;
				attack_phase = 1;
				attack_frame = 22;
				
				hsp = 20 * facing;
				
				var _dust = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_dust.sprite_index = spr_effect_step_dust;
				_dust.image_xscale = facing;
				_dust.anim_speed   = 0.2;
				_dust.lifetime     = sprite_get_number(spr_effect_step_dust) / _dust.anim_speed;
				_dust.owner        = id;
				obj_game.cam_shake = max(obj_game.cam_shake, 4);
				
				var _hitbox = hitbox_create(40, -20, 1.2, 0.8, 8, 10);
				_hitbox.hitlag = 8;
				_hitbox.knockback = 3;
				_hitbox.launch_speed = 2;
				_hitbox.hitstun = 55;
				_hitbox.low = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			anim_frame = ((22 - attack_frame) div 2) mod 8;
			
			if (attack_hit_confirmed())
				{
				attack_phase = 2;
				attack_frame = 40;
				hsp = -6 * facing;
				vsp = -11;
				
				var _imp = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_imp.sprite_index = spr_effect_landing_dust;
				_imp.image_xscale = facing;
				_imp.anim_speed   = 0.2;
				_imp.lifetime     = sprite_get_number(spr_effect_landing_dust) / _imp.anim_speed;
				_imp.owner        = id;
				obj_game.cam_shake = max(obj_game.cam_shake, 5);
				break;
				}
			
			player_move();
			
			if (attack_frame <= 0)
				{
				anim_sprite = spr_brad_roll_ini;
				anim_frame = 3;
				attack_phase = 4;
				attack_frame = 14;
				}
			}
		break;
		
		case 2:
			{
			attack_frame--;
			
			anim_frame = (attack_frame div 2) mod 8;
			
			vsp += grav;
			player_move();
			
			if ((bbox_bottom >= obj_ground.y && vsp > 0) || attack_frame <= 0)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				vsp = 0;
				
				var _land = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_land.sprite_index = spr_effect_landing_dust;
				_land.image_xscale = facing;
				_land.anim_speed   = 0.2;
				_land.lifetime     = sprite_get_number(spr_effect_landing_dust) / _land.anim_speed;
				_land.owner        = id;
				obj_game.cam_shake = max(obj_game.cam_shake, 6);
				
				attack_phase = 3;
				attack_frame = 14;
				hsp = 24 * facing;
				
				attack_connected = false;
				
				var _fin = hitbox_create(50, -20, 1.4, 1.0, 14, 14);
				_fin.hitlag = 13;
				_fin.knockback = 18;
				_fin.launch_speed = 14;
				_fin.hitstun = 40;
				_fin.knockdown = true;
				_fin.hit_angle = 30;
				}
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			anim_frame = (attack_frame div 2) mod 8;
			
			player_move();
			
			if (attack_frame <= 0)
				{
				anim_sprite = spr_brad_roll_ini;
				anim_frame = 3;
				attack_phase = 4;
				attack_frame = 8;
				}
			}
		break;
		
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 2;
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 0;
			
			hsp *= 0.5;
			player_move();
			
			if (attack_frame <= 0)
				{
				hsp = 0;
				attack_stop();
				break;
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */