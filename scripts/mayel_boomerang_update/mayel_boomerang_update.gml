function mayel_boomerang_update()
{
	if (owner.hitlag_frame > 0) return;
	
	// Control seguro del lifetime para que no expire antes de tiempo
	if (--lifetime <= 0) 
		{
		instance_destroy();
		return;
		}
	
	x += hsp;
	y += vsp;

	// --- MÁQUINA DE ESTADOS DEL BOOMERANG ---
	switch (boomerang_state)
		{
		case 0: // ESTADO 0: Viaje de ida (Avanza con velocidad normal)
			{
			if (abs(hsp) > 2)
				{
				hsp -= 0.3 * sign(hsp); // Desaceleración gradual
				}
			else
				{
				boomerang_state = 1; // Pasa al estado de frenado/pausa en el aire
				}
			}
		break;
		
		case 1: // ESTADO 1: Freno y pausa flotando en el aire (Estilo Kung Lao)
			{
			hsp = 0;
			brake_timer--;
			if (brake_timer <= 0)
				{
				boomerang_state = 2;    // Pasa al estado de retorno
				has_hit_return = false; // Permite golpear una vez de vuelta
				}
			}
		break;
		
		case 2: // ESTADO 2: Retorno guiado y acelerado hacia las manos de Mayel
			{
			var _dir = sign(owner.x - x);
			hsp += 0.8 * _dir;
			hsp = clamp(hsp, -18, 18);
			
			// Si el boomerang llega de vuelta a la posición exacta de Mayel, se destruye en sus manos
			if ((facing == 1 && x <= owner.x) || (facing == -1 && x >= owner.x))
				{
				instance_destroy();
				return;
				}
			}
		break;
		}
	
	// Colisión con otros proyectiles
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
	
	// --- COLISIÓN CON HURTBOXES (FILTRO DE 1 SOLO GOLPAZO POR TRAYECTORIA) ---
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
			
			var _puedo_golpear = false;
			if (boomerang_state != 2 && !has_hit_forward)
				{
				_puedo_golpear = true;
				has_hit_forward = true;
				}
			else if (boomerang_state == 2 && !has_hit_return)
				{
				_puedo_golpear = true;
				has_hit_return = true;
				}
			
			if (_puedo_golpear)
				{
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
					else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
						{
						anim_sprite = sprites[$ "low_block"];  
						player_state_set(PLAYER_STATE.blockstun);                   
						player_damage(other.damage * block_multiplier);
						state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
						other.owner.block_pushback = other.knockback * other.owner.facing;
						}
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
						other.owner.meter = clamp(other.owner.meter + 8, 0, other.owner.meter_max);
						}
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