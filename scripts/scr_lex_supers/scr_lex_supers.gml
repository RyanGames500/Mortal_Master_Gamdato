
function lex_super_missile(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_shot;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			hsp = 0;
			vsp = 0;
			super_invuln = true;
			ex_glow_color = make_colour_rgb(255, 150, 40);
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 1;
			
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 62;
				super_invuln = false;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 61 || attack_frame == 49 || attack_frame == 37 || attack_frame == 25)
				{
				lex_super_missile_fire((61 - attack_frame) div 12);
				hsp = -3 * facing;
				}
			
			hsp *= knockback_friction;
			
			if (attack_frame >= 25)
				{
				var _k = (61 - attack_frame) mod 12;
				anim_frame = (_k < 3) ? 2 : ((_k < 6) ? 3 : ((_k < 9) ? 4 : 1));
				}
			else if (attack_frame < 12)
				{
				anim_frame = min(7, 5 + floor((12 - attack_frame) / 5));
				}
			else
				{
				anim_frame = 4;
				}
			
			player_move();
			
			if (attack_frame <= 0)
				{
				ex_glow_color = make_colour_rgb(255, 40, 40);
				attack_stop();
				break;
				}
			}
		break;
		}
	}

function lex_super_missile_fire(_n)
	{
	var _last = (_n == 3);
	var _m = hitbox_create(120, -3, 0.7, 0.7, _last ? 16 : 12, 150);
	_m.destroy_on_stop = false;
	_m.custom_update = lex_super_missile_update;
	_m.custom_draw = lex_super_missile_draw;
	_m.facing = facing;
	_m.hsp = 0;
	_m.hitlag = _last ? 14 : 8;
	_m.launch_speed = _last ? 20 : 14;
	_m.knockback = 6;
	_m.knockdown = true;
	_m.hitstun = 50;
	
	_m.x0 = _m.x;
	_m.y0 = _m.y;
	_m.px = _m.x;
	_m.py = _m.y;
	_m.t_n = 0;
	_m.t_total = 34;
	_m.arc = 150 + ((_n mod 2) * 60);

	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_rocket_deploy);
	obj_game.cam_shake = max(obj_game.cam_shake, 6);
	}

function lex_super_missile_update()
	{
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	px = x;
	py = y;
	t_n++;
	var _p = clamp(t_n / t_total, 0, 1);
	var _opp = noone;
	with (obj_player)
		{
		if (id != other.owner) then _opp = id;
		}
	if (_opp != noone)
		{
		var _tx = _opp.x;
		var _ty = (_opp.bbox_top + _opp.bbox_bottom) * 0.5;
		x = lerp(x0, _tx, _p);
		y = lerp(y0, _ty, _p) - (arc * 4 * _p * (1 - _p));
		}
	else
		{
		x += 20 * facing;
		}
	
	if (t_n > t_total + 4) then to_be_destroyed = true;
	
	var _hitboxes = instance_place_array(x, y, obj_hitbox);
	for (var i = 0; i < array_length(_hitboxes); i++)
		{
		var _hitbox = _hitboxes[@ i];
		if (_hitbox.owner != owner && _hitbox.destroy_on_stop)
			{
			_hitbox.to_be_destroyed = true;
			}
		}
	
	var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
	for (var i = 0; i < array_length(_hurtboxes); i++)
		{
		var _hurtbox = _hurtboxes[@ i];
		
		if (_hurtbox.owner != owner)
			{
			if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
			if (_hurtbox.owner.npc_seq >= 0) then continue;
			
			with (_hurtbox.owner)
				{
				if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
					{
					anim_sprite = sprites[$ "high_block"];
					player_state_set(PLAYER_STATE.blockstun);
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					}
				else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
					{
					anim_sprite = sprites[$ "low_block"];
					player_state_set(PLAYER_STATE.blockstun);
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					}
				else
					{
					attack_stop();
					air_hits = 0;
					player_state_set(PLAYER_STATE.knockdown);
					anim_sprite = sprites[$ "knockdown"];
					anim_speed = anim_speed_default;
					anim_frame = 0;
					vsp = -other.launch_speed;
					
					player_damage(other.damage);
					combo_register_hit();
					state_frame = other.hitstun;
					hitlag_frame = other.hitlag;
					hsp = other.knockback * other.owner.facing;
					
					obj_game.cam_shake = max(obj_game.cam_shake, 14);
					}
				}
			
			with (owner)
				{
				meter = clamp(meter + 6, 0, meter_max);
				super_hit_fx = 5;
				}
			
			to_be_destroyed = true;
			}
		}
	
	if (to_be_destroyed)
		{
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_lex_shot_fizzle;
		_vfx.image_xscale = owner.sprite_scale * 1.8 * owner.facing;
		_vfx.image_yscale = owner.sprite_scale * 1.8;
		_vfx.anim_speed = 0.3;
		_vfx.lifetime = 23;
		_vfx.owner = owner;
		
		instance_destroy();
		return;
		}
	}

function lex_super_missile_draw()
	{
	var _s = owner.sprite_scale * 1.2;
	var _moved = (point_distance(px, py, x, y) > 0.5);
	var _dir = _moved ? point_direction(px, py, x, y) : ((facing == 1) ? 0 : 180);
	var _ang = (facing == 1) ? _dir : (_dir + 180);
	
	gpu_set_blendmode(bm_add);
	draw_sprite_ext(spr_lex_shot_projectile, lifetime div 5, x - lengthdir_x(40, _dir), y - lengthdir_y(40, _dir), _s * 1.5 * facing, _s, _ang, make_colour_rgb(255, 140, 40), 0.55);
	gpu_set_blendmode(bm_normal);
	
	palette_shader_texture_set(owner.palette_sprite, owner.player_number + 1);
	draw_sprite_ext(spr_lex_shot_projectile, lifetime div 5, x, y, _s * facing, _s, _ang, c_white, 1.0);
	shader_reset();
	}


function lex_super_cine(_override_phase)
	{
	static _tl = [
		super_ev(0,  spr_lex_light_ground,  5, 5),
		super_ev(4,  spr_lex_light_ground,  7),
		super_ev(8,  spr_lex_light_ground,  8),
		super_ev(10, spr_lex_light_ground,  9, 0, [100, -54, 2.0, 0.8, 7, 0, 3]),
		super_ev(14, spr_lex_light_ground, 12, 4),
		super_ev(20, spr_lex_light_ground, 13, 0, [85, -40, 2.0, 0.8, 7, 0, 3]),
		super_ev(26, spr_lex_shot2, 0, 6),
		super_ev(30, spr_lex_shot2, 1, 4, [110, -62, 2.0, 1.0, 4, 0, 10]),
		super_ev(36, spr_lex_shot2, 2, 4, [110, -62, 2.0, 1.0, 4, 0, 10]),
		super_ev(42, spr_lex_shot2, 1, 4, [110, -62, 2.0, 1.0, 5, 0, 12]),
		super_ev(48, spr_lex_shotgun, 0, 3),
		super_ev(52, spr_lex_shotgun, 1, 0, [120, -80, 2.4, 1.8, 10, 15, 8]),
		super_ev(56, spr_lex_shotgun, 2),
		super_ev(60, spr_lex_bomb, 1),
		super_ev(64, spr_lex_bomb, 2, 0, [90, -110, 1.8, 1.8, 8, 12, 0])
	];
	
	var _charge_len = SUPER_CHARGE_FRAMES;
	
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	if (_phase >= 0 && _phase <= 5) then vsp = 0;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_lex_shot;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(90, 255, 120);
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_sprite = spr_lex_dash;
				anim_frame = 0;
				attack_phase = 1;
				attack_frame = 18;
				hsp = 30 * facing;
				vsp = 0;
				
				var _dust = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_dust.sprite_index = spr_effect_step_dust;
				_dust.image_xscale = facing;
				_dust.anim_speed   = 0.2;
				_dust.lifetime     = sprite_get_number(spr_effect_step_dust) / _dust.anim_speed;
				_dust.owner        = id;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			var _ox = x + (400 * facing);
			with (obj_player)
				{
				if (id != other.id) then _ox = x;
				}
			
			if (abs(_ox - x) < 120 || attack_frame <= 0)
				{
				hsp = 0;
				attack_phase = 2;
				attack_frame = 14;
				attack_connected = false;
				super_invuln = false;
				anim_sprite = spr_lex_light_ground;
				anim_frame = 2;
				
				var _op = hitbox_create(100, -54, 2.0, 0.8, 4, 8);
				_op.hitlag = 4;
				_op.knockback = 3;
				_op.hitstun = 60;
				}
			
			player_move();
			}
		break;
		
		case 2:
			{
			attack_frame--;
			hsp = lerp(hsp, 0, 0.2);
			
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					attack_phase = 3;
					attack_frame = 0;
					super_invuln = true;
					super_lock = true;
					}
				else
					{
					anim_sprite = spr_lex_shot;
					anim_frame = 7;
					attack_phase = 6;
					attack_frame = 50;
					}
				}
			else if (attack_frame <= 0)
				{
				anim_sprite = spr_lex_shot;
				anim_frame = 7;
				attack_phase = 6;
				attack_frame = 50;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			super_timeline_run(_tl, attack_frame);
			attack_frame++;
			hsp = lerp(hsp, 0, 0.2);
			
			if (attack_frame > 70)
				{
				attack_phase = 4;
				attack_frame = _charge_len;
				anim_sprite = spr_lex_shot;
				anim_frame = 0;
				hsp = 0;
				}
			
			player_move();
			}
		break;
		
		case 4:
			{
			attack_frame--;
			
			with (obj_player)
				{
				if (id != other.id) then hitlag_frame = max(hitlag_frame, 2);
				}
			
			if (attack_frame == (_charge_len div 2)) then anim_frame = 1;
			
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 5;
				attack_frame = 24;
				attack_connected = false;
				super_lock = false;
				hsp = -14 * facing;
				
				var _fin = hitbox_create(150, -100, 3.4, 2.4, 20, 22);
				_fin.hitlag = 12;
				_fin.launch_speed = 24;
				_fin.high = true;
				_fin.knockback = 34;
				_fin.knockdown = true;
				_fin.hitstun = 70;
				
				super_hit_fx = 8;
				obj_game.cam_shake = max(obj_game.cam_shake, 10);
				}
			
			player_move();
			}
		break;
		
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 18) then anim_frame = 3;
			if (attack_frame == 12) then anim_frame = 4;
			
			hsp = lerp(hsp, 0, 0.1);
			
			if (attack_connected)
				{
				var _fx = instance_create_layer(x + (190 * facing), y - 100, "VFX_Layer", obj_vfx);
				_fx.sprite_index = spr_lex_shot_fizzle;
				_fx.image_xscale = 14 * facing;
				_fx.image_yscale = 14;
				_fx.anim_speed   = 0.3;
				_fx.lifetime     = sprite_get_number(spr_lex_shot_fizzle) / _fx.anim_speed;
				_fx.owner        = id;
				
				super_hit_fx = 16;
				obj_game.cam_shake = max(obj_game.cam_shake, 24);
				
				anim_frame = 5;
				attack_phase = 6;
				attack_frame = 40;
				super_invuln = false;
				}
			else if (attack_frame <= 0)
				{
				anim_frame = 7;
				attack_phase = 6;
				attack_frame = 50;
				super_invuln = false;
				}
			
			player_move();
			}
		break;
		
		case 6:
			{
			attack_frame--;
			
			if (attack_frame == 24) then anim_frame = 6;
			if (attack_frame == 12) then anim_frame = 7;
			
			hsp = lerp(hsp, 0, 0.12);
			player_move();
			
			if (attack_frame <= 0)
				{
				ex_glow_color = make_colour_rgb(255, 40, 40);
				attack_stop();
				break;
				}
			}
		break;
		}
	}