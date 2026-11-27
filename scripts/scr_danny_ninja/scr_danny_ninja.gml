#macro DANNY_WALL_HOLD	24
#macro DANNY_WALL_SLIDE	1
#macro DANNY_WALL_HSP	11
#macro DANNY_WALL_VSP	-20
#macro DANNY_SWAP_DIST	110
#macro DANNY_SWAP_OUT	8
#macro DANNY_SWAP_HIDE	12
#macro DANNY_SWAP_END	10

function danny_ninja_update()
	{
	if (dn_fx_wall >= 0 && ++dn_fx_wall > 40) then dn_fx_wall = -1;
	if (dn_fx_out >= 0 && ++dn_fx_out > 90) then dn_fx_out = -1;
	if (dn_fx_in >= 0 && ++dn_fx_in > 40) then dn_fx_in = -1;
	if (dn_bub_burst >= 0 && ++dn_bub_burst > 60) then dn_bub_burst = -1;
	if (dn_boom >= 0 && ++dn_boom > 40) then dn_boom = -1;
	if (dn_hit_t >= 0 && ++dn_hit_t > 10) then dn_hit_t = -1;
	if (dn_imp >= 0 && ++dn_imp > 50) then dn_imp = -1;

	if (bbox_bottom >= obj_ground.y) then wall_used = false;
	
	if (state == PLAYER_STATE.aerial && !wall_used && vsp > -8)
		{
		var _sd = inputs[@ INPUT.stick_dir];
		var _right = (_sd == STICK_DIR.forward || _sd == STICK_DIR.forward_up || _sd == STICK_DIR.forward_down);
		var _left = (_sd == STICK_DIR.backward || _sd == STICK_DIR.backward_up || _sd == STICK_DIR.backward_down);
		var _side = 0;
		if (bbox_right >= room_width - 2 && _right) then _side = 1;
		if (bbox_left <= 2 && _left) then _side = -1;
		if (_side != 0)
			{
			wall_side = _side;
			attack_start(danny_wall_cling);
			}
		}
	}

function danny_wall_cling(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = variable_struct_exists(sprites, "wall") ? sprites[$ "wall"] : sprites[$ "jump"];
			anim_frame = 0;
			anim_speed = 0;
			facing = -wall_side;
			hsp = 0;
			vsp = 0;
			attack_frame = 0;
			}
		break;
		
		case 0:
			{
			attack_frame++;
			vsp = DANNY_WALL_SLIDE;
			player_move(wall_side, vsp);
			
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			
			if (attack_frame > 2 && stick_check_direction(STICK_DIR.up_any))
				{
				wall_used = true;
				attack_stop();
				facing = -wall_side;
				hsp = DANNY_WALL_HSP * facing;
				vsp = DANNY_WALL_VSP;
				dn_fx_wall = 0;
				dn_wall_x = x;
				dn_wall_y = y;
				break;
				}
			
			if (attack_frame >= DANNY_WALL_HOLD)
				{
				wall_used = true;
				attack_stop();
				hsp = 0;
				}
			}
		break;
		
		case ATTACK_PHASE.stop:
		break;
		}
	}

function danny_swap(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = sprites[$ "idle"];
			anim_frame = 0;
			anim_speed = 0;
			hsp = 0;
			vsp = 0;
			attack_frame = 0;
			swap_hide = false;
			}
		break;
		
		case 0:
			{
			attack_frame++;
			
			if (attack_frame == DANNY_SWAP_OUT)
				{
				swap_hide = true;
				super_invuln = true;
				dn_fx_out = 0;
				dn_out_x = x;
				
				swap_tx = x;
				var _r = noone;
				with (obj_player)
					{
					if (id != other.id) then _r = id;
					}
				if (_r != noone)
					{
					var _dir = sign(_r.x - x);
					if (_dir == 0) then _dir = facing;
					var _tx = _r.x + _dir * DANNY_SWAP_DIST;
					if (_tx < 60 || _tx > room_width - 60) then _tx = _r.x - _dir * DANNY_SWAP_DIST;
					swap_tx = clamp(_tx, 60, room_width - 60);
					}
				}
			
			if (attack_frame == DANNY_SWAP_OUT + DANNY_SWAP_HIDE)
				{
				x = swap_tx;
				player_move(0, 0);
				swap_hide = false;
				super_invuln = false;
				player_face_opponent();
				dn_fx_in = 0;
				}
			
			if (attack_frame >= DANNY_SWAP_OUT + DANNY_SWAP_HIDE + DANNY_SWAP_END) then attack_stop();
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			swap_hide = false;
			super_invuln = false;
			}
		break;
		}
	}

function danny_gas(_cx, _cy, _age, _n, _k)
	{
	if (_age < 0 || _age >= 40) return;
	var _s = sprite_scale;
	for (var _i = 0; _i < _n; _i++)
		{
		var _px = _cx + (fatality_rnd(_i, _k) - 0.5) * 90;
		var _py = _cy + (fatality_rnd(_i, _k + 1) - 0.5) * 160 - _age * (0.6 + fatality_rnd(_i, _k + 2));
		var _sz = (_age < 12) ? _s * 2 : _s;
		var _c = _i mod 3;
		draw_set_colour((_c == 0) ? make_colour_rgb(80, 255, 180) : ((_c == 1) ? make_colour_rgb(150, 255, 200) : make_colour_rgb(40, 160, 110)));
		draw_set_alpha(0.85 * (1 - _age / 40));
		draw_rectangle(_px, _py, _px + _sz - 1, _py + _sz - 1, false);
		}
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function danny_draw_extra()
	{
	var _s = sprite_scale;
	
	if (state == PLAYER_STATE.attacking && attack_script == danny_wall_cling)
		{
		danny_gas(x + wall_side * 20, y, attack_frame mod 20, 4, 30);
		}
	danny_gas(dn_wall_x, dn_wall_y, dn_fx_wall, 14, 40);
	
	if (dn_fx_out >= 0)
		{
		var _gy = obj_ground.y;
		draw_set_colour(make_colour_rgb(200, 210, 215));
		draw_rectangle(dn_out_x - 4 * _s, _gy - 2 * _s, dn_out_x + 2 * _s, _gy - 1, false);
		draw_set_colour(make_colour_rgb(80, 255, 170));
		draw_set_alpha(0.7);
		draw_rectangle(dn_out_x - 3 * _s, _gy - _s, dn_out_x + 6 * _s, _gy, false);
		draw_set_alpha(1);
		draw_set_colour(c_white);
		}
	danny_gas(dn_out_x, y, dn_fx_out, 40, 50);
	danny_gas(x, y, dn_fx_in, 40, 60);

	if (danny_supers_draw()) return true;
	
	return swap_hide;
	}