function saori_special_dp(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_special_shoryu;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 3;
			
			hsp = 0;
			vsp = 0;
			
			invincible = true;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 90;
				
				hsp = 7 * facing;
				vsp = -25;
				
				invincible = true;
				
				var _hitbox = hitbox_create(76.5, -74, 0.6, 1, 10, 5);
				_hitbox.acid_finisher = true;
				_hitbox.hitlag = 12;
				_hitbox.launch_speed = 20;
				_hitbox.knockback = 12;
				_hitbox.hitstun = 45;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			var _elapsed = 90 - attack_frame;
			
			if (_elapsed >= 5) then invincible = false;
			
			vsp += grav;
			
			if (_elapsed == 2) then anim_frame = 2;
			if (_elapsed >= 4 && vsp < 3) then anim_frame = 3;
			if (vsp >= 3)  then anim_frame = 4;
			if (vsp >= 8)  then anim_frame = 5;
			if (vsp >= 12) then anim_frame = 6;
			
			if (_elapsed == 4)
				{
				var _hitbox_late = hitbox_create(76, -74, 0.7, 1, 6, 8);
				_hitbox_late.hitlag = 8;
				_hitbox_late.launch_speed = 12;
				_hitbox_late.knockback = 8;
				_hitbox_late.hitstun = 25;
				}
			
			player_move();
			
			if (bbox_bottom >= obj_ground.y && _elapsed > 6 && vsp > 0)
				{
				invincible = false;
				y = ceil(obj_ground.y - (bbox_bottom - y));
				hsp = 0;
				vsp = 0;
				
				var _land_sprite = sprites[$ "crouch"];
				if (!is_undefined(_land_sprite))
					{
					anim_sprite = _land_sprite;
					anim_frame = 0;
					anim_speed = anim_speed_default;
					}
				var _land_vfx = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_land_vfx.sprite_index = spr_effect_landing_dust;
				_land_vfx.image_xscale = facing;
				_land_vfx.anim_speed   = 0.2;
				_land_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _land_vfx.anim_speed;
				_land_vfx.owner        = id;
				
				attack_phase = 2;
				attack_frame = attack_connected ? 8 : 20;
				break;
				}
			
			if (attack_frame <= 0)
				{
				invincible = false;
				attack_stop();
				break;
				}
			}
		break;
		
		case 2:
			{
			attack_frame--;
			
			hsp = 0;
			vsp = 0;
			player_move();
			
			if (attack_frame == 5)
				{
				var _idle_sprite = sprites[$ "idle"];
				if (!is_undefined(_idle_sprite))
					{
					anim_sprite = _idle_sprite;
					anim_frame = 0;
					anim_speed = anim_idle_speed;
					}
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