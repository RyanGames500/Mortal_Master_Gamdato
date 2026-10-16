function bear_wave_hitbox_update()
	{
	//Lifetime
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	//Position
	x += hsp;
	
	//Se destruye al salir de la sala (nuestro)
	if (x < 0 || x > room_width)
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

			//Hitboxes that can only hit grounded opponents
			if (grounded_only)
				{
				if (_hurtbox.owner.bbox_bottom < obj_ground.y) then continue;
				}
			
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
					}
				else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
					{
					//Middle / Low block
					anim_sprite = sprites[$ "low_block"];   
					player_state_set(PLAYER_STATE.blockstun);                   
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
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
					
					//Effects
					obj_game.cam_shake = max(obj_game.cam_shake, other.shake);
					}
				}
			
			// El atacante gana la barra al conectar el proyectil
			with (owner)
				{
				meter = clamp(meter + 6, 0, meter_max);
				}
			
			//Projectiles are destroyed on hit
			to_be_destroyed = true;
			}
		}
	
	//Other destruction checks
	if (to_be_destroyed)
		{
		//VFX (nuestro: la chispa de impacto que ya tienes, hasta tener una propia)
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_effect_spark;
		_vfx.image_xscale = owner.facing;
		_vfx.anim_speed = 0.4;
		_vfx.lifetime = sprite_get_number(_vfx.sprite_index) / _vfx.anim_speed;
		_vfx.owner = owner;
		
		instance_destroy();
		return;     
		}
	}

/* Copyright 2024 Springroll Games / Yosi */