function bear_fire_hitbox_update()
	{
	//Lifetime
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	//Position (arco: gravedad fija, se congela durante el hitlag del dueño)
	if (owner.hitlag_frame <= 0)
		{
		vsp += 0.7;
		x += hsp;
		y += vsp;
		}
	
	//Toca el piso: explota (solo visual)
	if (y >= obj_ground.y - 40)
		{
		to_be_destroyed = true;
		}
	
	//Fuera de la zona de juego
	if (x < -300 || x > room_width + 300)
		{
		instance_destroy();
		return;
		}
	
	//Colliding with other projectiles will destroy both projectiles
	var _hitboxes = instance_place_array(x, y, obj_hitbox);
	for (var i = 0; i < array_length(_hitboxes); i++)
		{
		var _hitbox = _hitboxes[@ i];
		
		//You can't hit your own hurtboxes
		if (_hitbox.owner != owner)
			{
			//Check that the hitbox is a projectile
			if (_hitbox.destroy_on_stop)
				{
				to_be_destroyed = true;
				_hitbox.to_be_destroyed = true;
				}
			}
		}
	
	//Colliding with hurtboxes
	var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
	for (var i = 0; i < array_length(_hurtboxes); i++)
		{
		var _hurtbox = _hurtboxes[@ i];
		
		//You can't hit your own hurtboxes
		if (_hurtbox.owner != owner)
			{
			// Si la ronda no está en ejecución o el rival ya no tiene vida, ignorar colisión
			if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
			
			with (_hurtbox.owner)
				{
				//Blocking
				if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
					{
					//Middle / High block
					anim_sprite = sprites[$ "high_block"];
					player_state_set(PLAYER_STATE.blockstun);
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					meter = clamp(meter + 2, 0, meter_max);
					}
				else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
					{
					//Middle / Low block
					anim_sprite = sprites[$ "low_block"];
					player_state_set(PLAYER_STATE.blockstun);
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					meter = clamp(meter + 2, 0, meter_max);
					}
				//Hit
				else
					{
					attack_stop();
					
					//Grounded vs aerial hits
					if (bbox_bottom >= obj_ground.y && other.launch_speed == 0)
						{
						player_state_set(PLAYER_STATE.hitstun_ground);
						anim_sprite = sprites[$ "hitstun_ground"];
						anim_speed = anim_speed_default;
						player_face_opponent();
						vsp = 0;
						}
					else
						{
						player_state_set(PLAYER_STATE.hitstun_aerial);
						anim_sprite = sprites[$ "hitstun_aerial"];
						anim_speed = anim_speed_default;
						vsp = -other.launch_speed;
						}
					
					player_damage(other.damage);
					state_frame = other.hitstun;
					hitlag_frame = other.hitlag;
					hsp = other.knockback * other.owner.facing;
					meter = clamp(meter + 6, 0, meter_max);
					//Effects
					obj_game.cam_shake = max(obj_game.cam_shake, other.shake);
					}
				}
			
			//Projectiles are destroyed on hit
			to_be_destroyed = true;
			}
		}
	
	//Other destruction checks
	if (to_be_destroyed)
		{
		//VFX: explosión (solo visual, no hace daño)
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_bear_explosion;		// origen abajo-centro
		_vfx.image_xscale = owner.sprite_scale * facing;
		_vfx.image_yscale = owner.sprite_scale;
		_vfx.anim_speed = 0.25;
		_vfx.lifetime = 20;
		_vfx.owner = owner;
		
		//Si cayó al piso se apoya en él; si pegó en el aire queda centrada en el impacto
		if (y >= obj_ground.y - 40)
			{
			_vfx.y = obj_ground.y - 20;
			}
		else
			{
			_vfx.y = y + sprite_get_height(spr_bear_explosion) * owner.sprite_scale * 0.5;
			}
		
		instance_destroy();
		return;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */