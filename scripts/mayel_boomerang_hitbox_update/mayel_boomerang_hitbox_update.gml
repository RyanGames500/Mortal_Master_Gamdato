function mayel_boomerang_hitbox_update()
	{
	if (owner.hitlag_frame > 0) return;
	
	// --- LÓGICA DE IDA, FRENO Y RETORNO (Estilo Kung Lao / Rollback Safe) ---
	x += hsp;
	y += vsp; // Mantiene su altura o la que lleve

	// El boomerang frena progresivamente al avanzar hasta detenerse en el punto máximo
	if (abs(hsp) > 0.5)
		{
		hsp -= 0.35 * sign(hsp);
		}
	else
		{
		// Una vez que se detiene por completo en el aire, comienza el viaje de regreso hacia Mayel
		var _dir = sign(owner.x - x);
		hsp += 0.5 * _dir;
		hsp = clamp(hsp, -16, 16);
		
		// Si el boomerang regresa y toca o sobrepasa la posición de Mayel, se destruye
		if ((facing == 1 && x <= owner.x) || (facing == -1 && x >= owner.x))
			{
			instance_destroy();
			return;
			}
		}
	
	// Si toca el suelo por alguna razón, se destruye
	if (y >= obj_ground.y)
		{
		to_be_destroyed = true;
		}
	
	// Colisiones con otros proyectiles
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
	
	// Colisiones con hurtboxes (Rival)
	var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
	for (var i = 0; i < array_length(_hurtboxes); i++)
		{
		var _hurtbox = _hurtboxes[@ i];
		if (_hurtbox.owner != owner)
			{
			if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;

			with (_hurtbox.owner)
				{
				if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
					{
					anim_sprite = sprites[$ "high_block"];  
					player_state_set(PLAYER_STATE.blockstun);                   
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * other.owner.facing;
					}
				else
					{
					attack_stop();
					player_state_set(PLAYER_STATE.hitstun_aerial);
					anim_sprite = sprites[$ "hitstun_aerial"];
					anim_speed = anim_speed_default;
					vsp = -other.launch_speed;
					
					player_damage(other.damage);
					state_frame = other.hitstun;
					hitlag_frame = other.hitlag;
					hsp = other.knockback * other.owner.facing;
					
					obj_game.cam_shake = other.damage * 0.75;
					other.owner.meter = clamp(other.owner.meter + 8, 0, other.owner.meter_max);
					}
				}
			}
		}
	
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