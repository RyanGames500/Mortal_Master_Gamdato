#macro STAGE_PROP_MAX		4
#macro STAGE_PROP_RESPAWN	1200
#macro STAGE_PROP_DEBUG		false

function stage_prop(_x, _y_off, _sprite, _reach = 150, _scale = 6, _kind = 0)
	{
	return { x: _x, y_off: _y_off, sprite: _sprite, reach: _reach, scale: _scale, kind: _kind };
	}

function stage_props_get(_id)
	{
	switch (_id)
		{
		case 3: return [
			stage_prop((room_width div 2) - 650, -64, spr_botella, 120, 6, 1),
			stage_prop((room_width div 2) + 650, -64, spr_barril, 120, 6, 3),
			];
		
		case 4: return [
			stage_prop((room_width div 2) - 650, -32, spr_palo, 120, 6, 0),
			stage_prop((room_width div 2) + 650, -32, spr_roca, 120, 6, 2),
			];
		
		default: return [];
		}
	}

function stage_props_list()
	{
	if (obj_game.stage_props_for != obj_game.stage_id)
		{
		obj_game.stage_props = stage_props_get(obj_game.stage_id);
		obj_game.stage_props_for = obj_game.stage_id;
		}
	return obj_game.stage_props;
	}

function stage_prop_ready(_i)
	{
	var _u = obj_game.stage_prop_used[_i];
	return (_u != -1 && obj_game.game_frame >= _u);
	}

function stage_props_reset()
	{
	for (var _i = 0; _i < STAGE_PROP_MAX; _i++)
		{
		obj_game.stage_prop_used[@ _i] = 0;
		}
	}

function stage_props_check()
	{
	if (obj_game.game_meta_state != GAME_META_STATE.running) then return false;
	if (!special_state_ok()) then return false;
	if (bbox_bottom < obj_ground.y) then return false;
	if (variable_instance_exists(id, "can_use_props") && !can_use_props) then return false;
	if (!(input_pressed(INPUT.attack_light) && input_pressed(INPUT.attack_heavy))) then return false;
	
	var _props = stage_props_list();
	var _n = min(array_length(_props), STAGE_PROP_MAX);
	for (var _i = 0; _i < _n; _i++)
		{
		if (!stage_prop_ready(_i)) then continue;
		if (abs(x - _props[_i].x) > _props[_i].reach) then continue;
		
		input_reset(INPUT.attack_light);
		input_reset(INPUT.attack_heavy);
		obj_game.stage_prop_used[@ _i] = (STAGE_PROP_RESPAWN < 0) ? -1 : (obj_game.game_frame + STAGE_PROP_RESPAWN);
		
		var _kind = stage_prop_kind(_props[_i].kind);
		var _script = attacks[$ "heavy_ground"];
		if (variable_struct_exists(sprites, _kind.key))
			{
			prop_kind_id = _props[_i].kind;
			prop_index_id = _i;
			_script = stage_prop_attack;
			}
		attack_stop();
		attack_start(_script);
		return true;
		}
	return false;
	}

function stage_props_draw()
	{
	var _props = stage_props_list();
	var _n = min(array_length(_props), STAGE_PROP_MAX);
	for (var _i = 0; _i < _n; _i++)
		{
		var _p = _props[_i];
		var _y = obj_ground.y + _p.y_off;
		
		if (stage_prop_ready(_i))
			{
			if (sprite_exists(_p.sprite))
				{
				draw_sprite_ext(_p.sprite, 0, _p.x, _y, _p.scale, _p.scale, 0, c_white, 1);
				}
			else
				{
				draw_set_color(make_colour_rgb(120, 80, 40));
				draw_rectangle(_p.x - 30, _y - 120, _p.x + 30, _y, false);
				draw_set_color(c_white);
				}
			}
		
		if (STAGE_PROP_DEBUG)
			{
			draw_set_alpha(0.35);
			draw_set_color(stage_prop_ready(_i) ? c_lime : c_red);
			draw_rectangle(_p.x - _p.reach, _y - 200, _p.x + _p.reach, _y, false);
			draw_set_alpha(1);
			draw_set_color(c_white);
			}
			
	if (STAGE_PROP_DEBUG)
		{
		draw_set_color(c_yellow);
		var _tx = camera_get_view_x(camera_index) + 20;
		var _ty = camera_get_view_y(camera_index) + 20;
		draw_text(_tx, _ty, "stage_id=" + string(obj_game.stage_id) + "   objetos=" + string(array_length(_props)));
		for (var _k = 0; _k < instance_number(obj_player); _k++)
			{
			var _pl = instance_find(obj_player, _k);
			draw_text(_tx, _ty + 24 + (_k * 24), "jugador " + string(_k) + " x=" + string(floor(_pl.x)));
			}
		draw_set_color(c_white);
		}			
		}		
	}
	

function stage_prop_kind(_id)
	{
	if (!variable_global_exists("stage_prop_kinds"))
		{
		global.stage_prop_kinds =
			[
			{ key: "prop_palo", is_throw: false, frame_time: 4, hit_frame: 3,
			  hx: 230, hy: -70, hxs: 1.8, hys: 1.2, damage: 16, lifetime: 5,
			  hitlag: 14, launch_speed: 14, knockback: 14, knockdown: true },
			{ key: "prop_botella", is_throw: false, frame_time: 3, hit_frame: 2,
			  hx: 200, hy: -90, hxs: 1.2, hys: 1.0, damage: 12, lifetime: 4,
			  hitlag: 12, launch_speed: 8, knockback: 10, knockdown: false },
			{ key: "prop_roca", is_throw: true, frame_time: 4, hit_frame: 3,
			  hx: 80, hy: -110, hxs: 1.0, hys: 1.0, damage: 18, lifetime: 0,
			  hitlag: 14, launch_speed: 12, knockback: 14, knockdown: true,
			  p_hsp: 22, p_vsp: -6, grav: 0.7, spin: 18, rebound: false, destroy_sprite: -1, debris: spr_roca_trozos },
			{ key: "prop_barril", is_throw: true, frame_time: 4, hit_frame: 3,
			  hx: 80, hy: -90, hxs: 1.2, hys: 1.2, damage: 20, lifetime: 0,
			  hitlag: 14, launch_speed: 14, knockback: 16, knockdown: true,
			  p_hsp: 20, p_vsp: -3, grav: 0.55, spin: 12, rebound: true, destroy_sprite: -1, debris: -1 },
			];
		}
	return global.stage_prop_kinds[_id];
	}

function stage_prop_attack(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	var _k = stage_prop_kind(prop_kind_id);
	
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = sprites[$ _k.key];
			anim_frame = 0;
			anim_speed = 0;
			attack_frame = 0;
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame++;
			
			var _n = sprite_get_number(anim_sprite);
			anim_frame = min(floor(attack_frame / _k.frame_time), _n - 1);
			
			if (attack_frame == (_k.hit_frame * _k.frame_time))
				{
				if (_k.is_throw)
					{
					var _p = hitbox_create(_k.hx, _k.hy, _k.hxs, _k.hys, _k.damage, 400);
					_p.destroy_on_stop = true;
					_p.custom_update = stage_prop_proj_update;
					_p.custom_draw = stage_prop_proj_draw;
					_p.facing = facing;
					_p.hsp = _k.p_hsp * facing;
					_p.vsp = _k.p_vsp;
					_p.hitlag = _k.hitlag;
					_p.launch_speed = _k.launch_speed;
					_p.knockback = _k.knockback;
					_p.knockdown = _k.knockdown;
					_p.prop_idx = prop_index_id;
					_p.prop_kid = prop_kind_id;
					_p.proj_phase = 0;
					_p.proj_age = 0;
					_p.proj_angle = 0;
					_p.rest_timer = 0;
					_p.hit_done = false;
					}
				else
					{
					var _hitbox = hitbox_create(_k.hx, _k.hy, _k.hxs, _k.hys, _k.damage, _k.lifetime);
					_hitbox.hitlag = _k.hitlag;
					_hitbox.launch_speed = _k.launch_speed;
					_hitbox.knockback = _k.knockback;
					_hitbox.knockdown = _k.knockdown;
					}
				}
			
			player_move();
			
			if (attack_frame >= (_n * _k.frame_time))
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}
	
function stage_prop_proj_update()
	{
	if (owner.hitlag_frame > 0) then return;
	
	var _k = stage_prop_kind(prop_kid);
	var _list = stage_props_list();
	var _spr = (prop_idx < array_length(_list)) ? _list[prop_idx].sprite : -1;
	var _scale = (prop_idx < array_length(_list)) ? _list[prop_idx].scale : 6;
	var _half = sprite_exists(_spr) ? (sprite_get_height(_spr) * _scale * 0.5) : 30;
	
	if (--lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	proj_age++;
	
	if (proj_phase != 2)
		{
		x += hsp;
		y += vsp;
		vsp += _k.grav;
		proj_angle = proj_age * _k.spin * -facing;
		
		if ((y + _half) >= obj_ground.y)
			{
			if (_k.rebound)
				{
				y = obj_ground.y - _half;
				hsp = 0;
				vsp = 0;
				proj_phase = 2;
				proj_angle = 0;
				rest_timer = 45;
				}
			else
				{
				to_be_destroyed = true;
				}
			}
		}
	else
		{
		if (--rest_timer <= 0) then to_be_destroyed = true;
		}
	
	var _hitboxes = instance_place_array(x, y, obj_hitbox);
	for (var i = 0; i < array_length(_hitboxes); i++)
		{
		var _hb = _hitboxes[@ i];
		if (_hb.owner != owner && _hb.destroy_on_stop)
			{
			to_be_destroyed = true;
			_hb.to_be_destroyed = true;
			}
		}
	
	if (proj_phase != 2 && !hit_done)
		{
		var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
		for (var i = 0; i < array_length(_hurtboxes); i++)
			{
			var _hurtbox = _hurtboxes[@ i];
			if (_hurtbox.owner == owner) then continue;
			if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
			if (_hurtbox.owner.state == PLAYER_STATE.knockdown || _hurtbox.owner.state == PLAYER_STATE.acostado) then continue;
			if (_hurtbox.owner.rage_frames > 0) then continue;
			if (_hurtbox.owner.npc_seq >= 0) then continue;
			with (_hurtbox.owner)
				{
				var _vfx_x = x - (other.owner.facing * 12);
				var _vfx_y = clamp(other.y, bbox_top + 8, bbox_bottom - 8);
				
				if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
					{
					player_state_set(PLAYER_STATE.blockstun);
					anim_sprite = sprites[$ "high_block"];
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					hit_sfx_play(snd_block);
					var _bv = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
					_bv.sprite_index = spr_effect_spark3;
					_bv.image_xscale = other.owner.facing;
					_bv.anim_speed = 0.4;
					_bv.lifetime = sprite_get_number(_bv.sprite_index) / _bv.anim_speed;
					_bv.owner = other.owner;
					}
				else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
					{
					player_state_set(PLAYER_STATE.blockstun);
					anim_sprite = sprites[$ "low_block"];
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					hit_sfx_play(snd_block);
					var _bv2 = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
					_bv2.sprite_index = spr_effect_spark3;
					_bv2.image_xscale = other.owner.facing;
					_bv2.anim_speed = 0.4;
					_bv2.lifetime = sprite_get_number(_bv2.sprite_index) / _bv2.anim_speed;
					_bv2.owner = other.owner;
					}
				else
					{
					attack_stop();
					var _was_frozen = frozen;
					
					var _snd_heavy_list = [snd_hit_heavy, snd_hit_heavy_2, snd_hit_heavy_3];
					hit_sfx_play(_snd_heavy_list[other.owner.sound_hit_heavy_index]);
					other.owner.sound_hit_heavy_index = (other.owner.sound_hit_heavy_index + 1) % array_length(_snd_heavy_list);
					
					var _hit_sprites = [spr_effect_spark, spr_effect_spark2];
					var _spark = instance_create_layer(_vfx_x, _vfx_y, "VFX_Layer", obj_vfx);
					_spark.sprite_index = _hit_sprites[(obj_game.game_frame + other.owner.player_number) mod 2];
					_spark.image_xscale = other.owner.facing;
					_spark.anim_speed = 0.4;
					_spark.lifetime = sprite_get_number(_spark.sprite_index) / _spark.anim_speed;
					_spark.owner = other.owner;
					
					blood_spray(_vfx_x, _vfx_y, other.owner.facing, clamp(round(other.damage * 1.5), 8, 26), 0.5, 2, other.hitlag);
					
					if (other.knockdown || air_hits >= air_hit_limit)
						{
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
					
					var _final_damage = other.damage * max(0.4, 1 - 0.2 * max(air_hits - 1, 0));
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
					
					obj_game.cam_shake = max(obj_game.cam_shake, SHAKE_HEAVY);
					if (other.damage > 10)
						{
						var _al = instance_create_layer(x, y, "VFX_Layer", obj_vfx_action_lines);
						_al.lifetime = other.damage;
						}
					}
				}
			
			with (owner)
				{
				meter = clamp(meter + 16, 0, meter_max);
				}
			
			hit_done = true;
			if (_k.rebound)
				{
				hsp = -sign(hsp) * 6;
				vsp = -10;
				proj_phase = 1;
				}
			else
				{
				to_be_destroyed = true;
				}
			break;
			}
		}
	
	if (to_be_destroyed)
		{
		if (variable_struct_exists(_k, "destroy_sprite") && sprite_exists(_k.destroy_sprite))
			{
			var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
			_vfx.sprite_index = _k.destroy_sprite;
			_vfx.image_xscale = _scale;
			_vfx.image_yscale = _scale;
			_vfx.anim_speed = 0.3;
			_vfx.lifetime = ceil(sprite_get_number(_k.destroy_sprite) / 0.3);
			_vfx.owner = owner;
			}
		
		if (variable_struct_exists(_k, "debris") && sprite_exists(_k.debris))
			{
			var _np = sprite_get_number(_k.debris);
			for (var _d = 0; _d < _np; _d++)
				{
				var _c = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
				_c.sprite_index = _k.debris;
				_c.image_index = _d;
				_c.anim_speed = 0;
				_c.lifetime = 40;
				_c.owner = owner;
				_c.image_xscale = _scale;
				_c.image_yscale = _scale;
				_c.debris_hsp = ((((_d * 37) mod 11) - 5) * 2.2) + (hsp * 0.5);
				_c.debris_vsp = -(8 + ((_d * 53) mod 7) * 1.6);
				_c.debris_spin = (((_d * 29) mod 9) - 4) * 9;
				}
			}
		
		instance_destroy();
		return;
		}
	}

function stage_prop_proj_draw()
	{
	var _list = stage_props_list();
	if (prop_idx >= array_length(_list)) then return;
	var _spr = _list[prop_idx].sprite;
	var _s = _list[prop_idx].scale;
	
	if (!sprite_exists(_spr))
		{
		draw_set_color(make_colour_rgb(120, 80, 40));
		draw_rectangle(x - 30, y - 30, x + 30, y + 30, false);
		draw_set_color(c_white);
		return;
		}
	
	var _dx = (sprite_get_width(_spr) * 0.5) - sprite_get_xoffset(_spr);
	var _dy = (sprite_get_height(_spr) * 0.5) - sprite_get_yoffset(_spr);
	var _rx = ((_dx * dcos(proj_angle)) + (_dy * dsin(proj_angle))) * _s;
	var _ry = ((-_dx * dsin(proj_angle)) + (_dy * dcos(proj_angle))) * _s;
	draw_sprite_ext(_spr, 0, x - _rx, y - _ry, _s, _s, proj_angle, c_white, 1.0);
	}	