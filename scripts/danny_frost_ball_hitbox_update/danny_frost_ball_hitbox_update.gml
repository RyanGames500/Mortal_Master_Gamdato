function danny_frost_ball_hitbox_update()
	{
	//Lifetime
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	//Acelera mientras viaja (nace lenta, llega a 14)
	var _spd = min(abs(hsp) + 0.4, 14);
	hsp = _spd * facing;
	
	//Position
	x += hsp;
	
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
			// No pega a rivales ya caídos
			if (_hurtbox.owner.state == PLAYER_STATE.knockdown || _hurtbox.owner.state == PLAYER_STATE.acostado) then continue;
			// Rage: los proyectiles no le hacen daño
			if (_hurtbox.owner.rage_frames > 0) then continue;

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
					hit_sfx_play(snd_block);
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
					hit_sfx_play(snd_block);
					meter = clamp(meter + 2, 0, meter_max);
					}
				//Hit
				else
					{
					attack_stop();
					
					if (bbox_bottom >= obj_ground.y && other.launch_speed == 0)
						{
						// En el suelo: queda congelado
						air_hits = 0;
						player_state_set(PLAYER_STATE.hitstun_ground);
						anim_sprite = sprites[$ "hitstun_ground"];
						anim_speed = 0;
						anim_frame = 0;
						player_face_opponent();
						frozen = true;
						hsp = 0;
						vsp = 0;
						state_frame = 50;   // duración del congelado
						}
					else
						{
						// En el aire: golpe normal
						air_hits++;
						player_state_set(PLAYER_STATE.hitstun_aerial);
						anim_sprite = sprites[$ "hitstun_aerial"];
						anim_speed = anim_speed_default;
						vsp = -other.launch_speed;
						state_frame = other.hitstun;
						hsp = other.knockback * other.owner.facing;
						}
					
					player_damage(other.damage);
					combo_register_hit();
					hitlag_frame = other.hitlag;
					hit_sfx_play(snd_hit_heavy);
					meter = clamp(meter + 6, 0, meter_max);
					obj_game.cam_shake = max(obj_game.cam_shake, other.damage * 0.75);
					}
				}
			
			//Projectiles are destroyed on hit
			to_be_destroyed = true;
			}
		}
	
	//Other destruction checks
	if (to_be_destroyed)
		{
		//VFX: el hielo se rompe
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_danny_iceblock;
		_vfx.image_xscale = owner.sprite_scale * 0.5 * facing;
		_vfx.image_yscale = owner.sprite_scale * 0.5;
		_vfx.anim_speed = 0.4;
		_vfx.lifetime = sprite_get_number(spr_danny_iceblock) / _vfx.anim_speed;
		_vfx.owner = owner;
		
		instance_destroy();
		return;		
		}
	}