function mayel_hammer_hitbox_update()
	{
	//Lifetime
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	//Física parabólica (Determinista)
	x += hsp;
	y += vsp;
	vsp += 0.4; // Gravedad constante aplicada al proyectil
	
	// Si la bomba toca el suelo se destruye/explota
	if (y >= obj_ground.y)
		{
		to_be_destroyed = true;
		}
	
	//Colliding with other projectiles will destroy both projectiles
	var _hitboxes = instance_place_array(x, y, obj_hitbox);
	for (var i = 0; i < array_length(_hitboxes); i++)
		{
		var _hitbox = _hitboxes[@ i];
		
		if (_hitbox.owner != owner)
			{
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
		
		if (_hurtbox.owner != owner)
			{
			if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;

			if (grounded_only)
				{
				if (_hurtbox.owner.bbox_bottom < obj_ground.y) then continue;
				}
			
			with (_hurtbox.owner)
				{
				//Blocking (El rival NO recibe meter)
				if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
					{
					anim_sprite = sprites[$ "high_block"];  
					player_state_set(PLAYER_STATE.blockstun);                   
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * other.owner.facing;
					}
				else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
					{
					anim_sprite = sprites[$ "low_block"];   
					player_state_set(PLAYER_STATE.blockstun);                   
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * other.owner.facing;
					}
				//Hit
				else
					{
					attack_stop();
					
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
					
					obj_game.cam_shake = other.damage * 0.75;
					
					// ÚNICAMENTE EL ATACANTE SUMA METER
					other.owner.meter = clamp(other.owner.meter + 8, 0, other.owner.meter_max);
					}
				}
			
			to_be_destroyed = true;
			}
		}
	
	//Other destruction checks (Explosión / Fizzle)
	if (to_be_destroyed)
		{
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_mayel_martillo_destroy;
		_vfx.image_xscale = owner.sprite_scale * owner.facing;
		_vfx.image_yscale = owner.sprite_scale;
		_vfx.anim_speed = 0.3;
		_vfx.lifetime = 23;
		_vfx.owner = owner;
		
		instance_destroy();
		return;     
		}
	}