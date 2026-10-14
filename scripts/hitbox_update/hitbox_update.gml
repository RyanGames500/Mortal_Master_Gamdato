function hitbox_update()
	{
	//Custom update script
	if (custom_update != -1 && script_exists(custom_update))
		{
		script_execute(custom_update);
		return;
		}
	
	//Lifetime
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	//Position
	x = owner.x + (x_offset * owner.facing);
	y = owner.y + y_offset;
	
	//Colliding with hurtboxes
	if (!owner.attack_connected)
		{
		var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
		for (var i = 0; i < array_length(_hurtboxes); i++)
			{
			var _hurtbox = _hurtboxes[@ i];
			
			//You can't hit your own hurtboxes
			if (_hurtbox.owner != owner)
				{
				// Si la ronda no está en ejecución o el rival ya no tiene vida, ignorar colisión
				if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
				if (_hurtbox.owner.state == PLAYER_STATE.knockdown || _hurtbox.owner.state == PLAYER_STATE.acostado) then continue;
				// Rage: los proyectiles no le hacen daño (los golpes normales sí)
				if (destroy_on_stop && _hurtbox.owner.rage_frames > 0) then continue;
				//Hitboxes that can only hit grounded opponents
				if (grounded_only)
					{
					if (_hurtbox.owner.bbox_bottom < obj_ground.y) then continue;
					}
				
				with (_hurtbox.owner)
					{
					// ==========================================
					// POSICIÓN ESTILO KOF (Sobre la Hurtbox del Receptor)
					// ==========================================
					// Nacimiento en el borde del cuerpo del golpeado orientado hacia el impacto
					var _vfx_x = x - (other.owner.facing * 12); 
					var _vfx_y = clamp(other.y, bbox_top + 8, bbox_bottom - 8);

					// ==========================================
					// 1. AGARRES (GRABS)
					// ==========================================
					if (other.grab)
						{
						attack_stop();
						player_state_set(PLAYER_STATE.grabbed);
						combo_register_hit();
						anim_sprite = sprites[$ "hitstun_ground"];
						anim_speed = anim_speed_default;
						player_face_opponent();
						player_damage(other.damage);
						state_frame = other.hitstun;
						hitlag_frame = other.hitlag;
						hsp = 0;
						vsp = 0;
						}
					
					// ==========================================
					// 2. BLOQUEO ALTO / MEDIO (HIGH BLOCK)
					// ==========================================
					else if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
						{
						player_state_set(PLAYER_STATE.blockstun);
						anim_sprite = sprites[$ "high_block"];  
						player_damage(other.damage * block_multiplier);
						state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
						other.owner.block_pushback = other.knockback * facing;
						
						hit_sfx_play(snd_block);

						// --- VFX CHISPA DE BLOQUEO SOBRE EL DEFENSOR ---
						var _block_vfx = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
						_block_vfx.sprite_index = spr_effect_spark3;
						_block_vfx.image_xscale = other.owner.facing;
						_block_vfx.anim_speed   = 0.4;
						_block_vfx.lifetime     = sprite_get_number(_block_vfx.sprite_index) / _block_vfx.anim_speed;
						_block_vfx.owner        = other.owner;
						}

					// ==========================================
					// 3. BLOQUEO BAJO (LOW BLOCK)
					// ==========================================
					else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
						{
						player_state_set(PLAYER_STATE.blockstun);
						anim_sprite = sprites[$ "low_block"];   
						player_damage(other.damage * block_multiplier);
						state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
						other.owner.block_pushback = other.knockback * facing;
						
						hit_sfx_play(snd_block);

						// --- VFX CHISPA DE BLOQUEO BAJO ---
						var _block_vfx = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
						_block_vfx.sprite_index = spr_effect_spark3;
						_block_vfx.image_xscale = other.owner.facing;
						_block_vfx.anim_speed   = 0.4;
						_block_vfx.lifetime     = sprite_get_number(_block_vfx.sprite_index) / _block_vfx.anim_speed;
						_block_vfx.owner        = other.owner;
						}

					// ==========================================
					// 4. IMPACTO LIMPIO (HIT)
					// ==========================================
					else
						{
						attack_stop();
						var _was_frozen = frozen;
						// Sonidos de impacto
						var _snd_heavy_list = [snd_hit_heavy, snd_hit_heavy_2, snd_hit_heavy_3];
						var _snd_light_list = [snd_hit_light, snd_hit_light_2, snd_hit_light_3];

						if (other.damage > 8)
							{
							var _sound_to_play = _snd_heavy_list[other.owner.sound_hit_heavy_index];
							hit_sfx_play(_sound_to_play);
							
							other.owner.sound_hit_heavy_index = (other.owner.sound_hit_heavy_index + 1) % array_length(_snd_heavy_list);
							}
						else
							{
							var _sound_to_play = _snd_light_list[other.owner.sound_hit_light_index];
							hit_sfx_play(_sound_to_play);
							
							other.owner.sound_hit_light_index = (other.owner.sound_hit_light_index + 1) % array_length(_snd_light_list);
							}

						// --- VFX CHISPA DE IMPACTO: alterna entre spark1 y spark2 (determinista, sin random) ---
						var _hit_sprites = [spr_effect_spark, spr_effect_spark2];
						var _spark = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
						_spark.sprite_index = _hit_sprites[(obj_game.game_frame + other.owner.player_number) mod 2];
						_spark.image_xscale = other.owner.facing;
						_spark.anim_speed   = 0.4;
						_spark.lifetime     = sprite_get_number(_spark.sprite_index) / _spark.anim_speed;
						_spark.owner        = other.owner;
						
						// Sangre: sale al terminar el congelado del golpe
						if (other.launch_speed > 0)
							{
							// Lanzador (uppercut): sube en abanico
							blood_spray(_vfx_x, _vfx_y, other.owner.facing, clamp(round(other.damage * 1.5), 8, 26), 0.5, 2, other.hitlag);
							}
						else
							{
							// Golpe normal: sale hacia donde va el golpe
							blood_spray(_vfx_x, _vfx_y, other.owner.facing, clamp(round(other.damage * 1.2), 3, 14), 1, 0.7, other.hitlag);
							}
						
						// Reacción de Hitstun (Suelo vs Remate/Límite vs Aire)
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
							// Golpe en el aire o lanzador de juggle
							air_hits++;
							player_state_set(PLAYER_STATE.hitstun_aerial);
							anim_sprite = sprites[$ "hitstun_aerial"];
							anim_speed = anim_speed_default;
							vsp = -other.launch_speed;
							}
						
						// Daño final de este golpe (se calcula antes para saber si es el golpe mortal)
						var _final_damage = other.damage * max(0.4, 1 - 0.2 * max(air_hits - 1, 0));
						
						if (other.acid_finisher && obj_game.stage_has_acid && ceil(hp - _final_damage) <= 0)
							{
							var _killer_wins = (other.owner.player_number == 0) ? obj_game.p1_wins : obj_game.p2_wins;
							if (_killer_wins >= obj_game.rounds_to_win - 1)
								{
								acid_ko = true;
								acid_x = x;
								acid_y = y;
								acid_dir = other.owner.facing;
								}
							}
						
						player_damage(_final_damage);
						combo_register_hit();
						state_frame = other.hitstun;
						hitlag_frame = other.hitlag;
						hsp = other.knockback * other.owner.facing;
						if (_was_frozen)
							{
							air_hits = 0;
							player_state_set(PLAYER_STATE.knockdown);
							anim_sprite = sprites[$ "knockdown"];
							anim_speed = anim_speed_default;
							anim_frame = 0;
							vsp = -9;
							hsp = 4 * other.owner.facing;
							player_damage(5);
							}
						frozen = false;
						// Cámara: los golpes que lanzan o tiran al suelo tiemblan como el aterrizaje
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
				
				// ÚNICAMENTE EL ATACANTE GANA BARRA METER
				with (owner)
					{
					attack_connected = true;
					hitlag_frame = other.hitlag;
					meter = clamp(meter + 16, 0, meter_max);
					}
				}
			}
		}
	
	// Other destruction checks
	if (to_be_destroyed || owner.state != PLAYER_STATE.attacking)
		{
		instance_destroy();
		return;     
		}
	}
/* Copyright 2024 Springroll Games / Yosi */