function demon_proyectil(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_demon_especial2; 
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 8;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup (frames 0 a 2)
		case 0:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 4) then anim_frame = 1;
			
			//Dispara en el frame 2
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 30;
				
				//No se puede lanzar otro si ya hay uno en pantalla
				var _exists = false;
				with (obj_hitbox)
					{
					if (owner == other.id && custom_update == demon_proyectil_hitbox_update)
						{
						_exists = true;
						break;
						}
					}
				if (!_exists)
					{
					var _hitbox = hitbox_create(151, -82, 1, 1, 20, 120);
					_hitbox.destroy_on_stop = true;
					_hitbox.custom_update = demon_proyectil_hitbox_update;
					_hitbox.custom_draw = demon_proyectil_hitbox_draw;
					_hitbox.hsp = 25 * facing;
					_hitbox.knockdown = true;
					_hitbox.knockback = 15;
					_hitbox.hitstun = 20;
					_hitbox.launch_speed = 15;
					_hitbox.facing = facing;
					}
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Recuperacion (frames 3 a 9)
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 28) then anim_frame = 3;
			if (attack_frame == 24) then anim_frame = 4;
			if (attack_frame == 20) then anim_frame = 5;
			if (attack_frame == 16) then anim_frame = 6;
			if (attack_frame == 12) then anim_frame = 7;
			if (attack_frame == 8)  then anim_frame = 8;
			if (attack_frame == 4)  then anim_frame = 9;
			
			//Movement
			player_move();
			
			//Stop
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}

function demon_proyectil_hitbox_draw()
	{
	//Outline
	//draw_sprite_ext(spr_blocky_hadoken_projectile, lifetime div 5, x + owner.sprite_scale, y, owner.sprite_scale * facing, owner.sprite_scale, 0, c_black, 1.0);
	//draw_sprite_ext(spr_blocky_hadoken_projectile, lifetime div 5, x - owner.sprite_scale, y, owner.sprite_scale * facing, owner.sprite_scale, 0, c_black, 1.0);
	//draw_sprite_ext(spr_blocky_hadoken_projectile, lifetime div 5, x, y + owner.sprite_scale, owner.sprite_scale * facing, owner.sprite_scale, 0, c_black, 1.0);
	//draw_sprite_ext(spr_blocky_hadoken_projectile, lifetime div 5, x, y - owner.sprite_scale, owner.sprite_scale * facing, owner.sprite_scale, 0, c_black, 1.0);
	
	//Draw the projectile
	palette_shader_texture_set(owner.palette_sprite, owner.player_number + 1)
	draw_sprite_ext(spr_demon_projectile, lifetime div 5, x, y, owner.sprite_scale * facing, owner.sprite_scale, 0, c_white, 1.0);
	shader_reset();
	}

function demon_proyectil_hitbox_update()
	{
	//Lifetime
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
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
			// Rival ya derribado: el proyectil lo atraviesa (igual que los golpes normales)
			if (_hurtbox.owner.state == PLAYER_STATE.knockdown || _hurtbox.owner.state == PLAYER_STATE.acostado) then continue;
			// Rage: los proyectiles no le hacen daño
			if (destroy_on_stop && _hurtbox.owner.rage_frames > 0) then continue;

			//Hitboxes that can only hit grounded opponents
			if (grounded_only)
				{
				if (_hurtbox.owner.bbox_bottom < obj_ground.y) then continue;
				}
			
			with (_hurtbox.owner)
				{
				// Posición de los efectos sobre el cuerpo del golpeado
				var _vfx_x = x - (other.facing * 12);
				var _vfx_y = clamp(other.y, bbox_top + 8, bbox_bottom - 8);
				
				//Blocking (alto / medio)
				if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
					{
					player_state_set(PLAYER_STATE.blockstun);
					anim_sprite = sprites[$ "high_block"];
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					meter = clamp(meter + 2, 0, meter_max);
					
					hit_sfx_play(snd_block);
					var _block_vfx = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
					_block_vfx.sprite_index = spr_effect_spark3;
					_block_vfx.image_xscale = other.facing;
					_block_vfx.anim_speed   = 0.4;
					_block_vfx.lifetime     = sprite_get_number(_block_vfx.sprite_index) / _block_vfx.anim_speed;
					_block_vfx.owner        = other.owner;
					}
				//Blocking (bajo)
				else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
					{
					player_state_set(PLAYER_STATE.blockstun);
					anim_sprite = sprites[$ "low_block"];
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					meter = clamp(meter + 2, 0, meter_max);
					
					hit_sfx_play(snd_block);
					var _block_vfx = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
					_block_vfx.sprite_index = spr_effect_spark3;
					_block_vfx.image_xscale = other.facing;
					_block_vfx.anim_speed   = 0.4;
					_block_vfx.lifetime     = sprite_get_number(_block_vfx.sprite_index) / _block_vfx.anim_speed;
					_block_vfx.owner        = other.owner;
					}
				//Hit
				else
					{
					attack_stop();
					var _was_frozen = frozen;
					
					// Sonido de impacto
					var _snd_heavy_list = [snd_hit_heavy, snd_hit_heavy_2, snd_hit_heavy_3];
					var _snd_light_list = [snd_hit_light, snd_hit_light_2, snd_hit_light_3];
					if (other.damage > 8)
						{
						hit_sfx_play(_snd_heavy_list[other.owner.sound_hit_heavy_index]);
						other.owner.sound_hit_heavy_index = (other.owner.sound_hit_heavy_index + 1) % array_length(_snd_heavy_list);
						}
					else
						{
						hit_sfx_play(_snd_light_list[other.owner.sound_hit_light_index]);
						other.owner.sound_hit_light_index = (other.owner.sound_hit_light_index + 1) % array_length(_snd_light_list);
						}
					
					// Chispa de impacto (determinista, sin random)
					var _hit_sprites = [spr_effect_spark, spr_effect_spark2];
					var _spark = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
					_spark.sprite_index = _hit_sprites[(obj_game.game_frame + other.owner.player_number) mod 2];
					_spark.image_xscale = other.facing;
					_spark.anim_speed   = 0.4;
					_spark.lifetime     = sprite_get_number(_spark.sprite_index) / _spark.anim_speed;
					_spark.owner        = other.owner;
					
					// Sangre
					if (other.launch_speed > 0)
						{
						blood_spray(_vfx_x, _vfx_y, other.facing, clamp(round(other.damage * 1.5), 8, 26), 0.5, 2, other.hitlag);
						}
					else
						{
						blood_spray(_vfx_x, _vfx_y, other.facing, clamp(round(other.damage * 1.2), 3, 14), 1, 0.7, other.hitlag);
						}
					
					// Reacción de hitstun (suelo / remate o límite / aire)
					if (bbox_bottom >= obj_ground.y && other.launch_speed == 0)
						{
						air_hits = 0;
						player_state_set(PLAYER_STATE.hitstun_ground);
						anim_sprite = sprites[$ "hitstun_ground"];
						anim_speed = anim_speed_default;
						player_face_opponent();
						vsp = 0;
						}
					else if (other.knockdown || air_hits >= air_hit_limit)
						{
						// Remate o límite de combo: sale volando y cae acostado
						air_hits = 0;
						player_state_set(PLAYER_STATE.knockdown);
						anim_sprite = sprites[$ "knockdown"];
						anim_speed = anim_speed_default;
						anim_frame = 0;
						vsp = -other.launch_speed;
						}
					else
						{
						air_hits++;
						player_state_set(PLAYER_STATE.hitstun_aerial);
						anim_sprite = sprites[$ "hitstun_aerial"];
						anim_speed = anim_speed_default;
						vsp = -other.launch_speed;
						}
					
					// Daño final (se calcula antes para saber si es el golpe mortal)
					var _final_damage = other.damage * max(0.4, 1 - 0.2 * max(air_hits - 1, 0));
					
					if (other.acid_finisher && (obj_game.stage_has_acid || obj_game.stage_has_root) && ceil(hp - _final_damage) <= 0)
						{
						var _killer_wins = (other.owner.player_number == 0) ? obj_game.p1_wins : obj_game.p2_wins;
						if (_killer_wins >= obj_game.rounds_to_win - 1)
							{
							acid_ko = true;
							acid_x = x;
							acid_y = y;
							acid_dir = other.facing;
							}
						}
					
					player_damage(_final_damage);
					combo_register_hit();
					state_frame = other.hitstun;
					hitlag_frame = other.hitlag;
					hsp = other.knockback * other.facing;
					if (_was_frozen)
						{
						air_hits = 0;
						player_state_set(PLAYER_STATE.knockdown);
						anim_sprite = sprites[$ "knockdown"];
						anim_speed = anim_speed_default;
						anim_frame = 0;
						vsp = -9;
						hsp = 4 * other.facing;
						player_damage(5);
						}
					frozen = false;
					
					// Cámara: los golpes que lanzan o tiran al suelo tiemblan fuerte
					var _shake = other.shake;
					if (other.launch_speed > 0 || other.knockdown) then _shake = max(_shake, SHAKE_HEAVY);
					obj_game.cam_shake = max(obj_game.cam_shake, _shake);
					
					// Líneas de acción
					if (other.damage > 10)
						{
						var _action_lines = instance_create_layer(x, y, "VFX_Layer", obj_vfx_action_lines);
						_action_lines.lifetime = other.damage;
						}
					}
				}
			
			//Projectiles are destroyed on hit
			to_be_destroyed = true;
			}
		}
	
	//Other destruction checks
	if (to_be_destroyed)
		{
		//VFX
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_demon_projectile_explod;
		_vfx.image_xscale = owner.sprite_scale * facing;
		_vfx.image_yscale = owner.sprite_scale;
		_vfx.anim_speed = 0.3;
		_vfx.lifetime = 23;
		_vfx.owner = owner;
		
		instance_destroy();
		return;		
		}
	}

/* Copyright 2024 Springroll Games / Yosi */