
#macro WHIP_LOOPS			2
#macro WHIP_CHARGE			10
#macro WHIP_T_VINE			2
#macro WHIP_T_MOVE			1
#macro WHIP_T_IDLE			1
#macro WHIP_END_LAG			10
#macro WHIP_MISS_LAG		22

function blitsen_whip_table()
	{
	var _types = "mvvmmiiivvmiivvmmiiivvmi";
	
	var _hits = array_create(24, undefined);
	_hits[@ 1]  = [291, -11, 2.92, 0.62, 0];
	_hits[@ 8]  = [291, -44, 2.92, 0.80, 1];
	_hits[@ 13] = [291, -47, 2.92, 0.85, 1];
	_hits[@ 20] = [280,  77, 2.75, 1.20, 2];
	
	var _tb = [];
	var _t = 0;
	for (var k = 0; k < 24; k++)
		{
		var _c = string_char_at(_types, k + 1);
		var _d = WHIP_T_IDLE;
		if (_c == "v")
			{
			_d = WHIP_T_VINE;
			}
		else if (_c == "m")
			{
			_d = WHIP_T_MOVE;
			}
		array_push(_tb, { f: k, start: _t, dur: _d, hit: _hits[k] });
		_t += _d;
		}
	
	return { frames: _tb, len: _t };
	}

function blitsen_super_whip(_override_phase)
	{
	static _tb = blitsen_whip_table();
	static _dmg = [[6, 6, 6, 7], [6, 6, 6, 14]];
	static _which = [-1, 0, -1, -1, -1, -1, -1, -1, 1, -1, -1, -1, -1, 2, -1, -1, -1, -1, -1, -1, 3, -1, -1, -1];
	
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_super_whip;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = WHIP_CHARGE;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			ex_glow_color = make_colour_rgb(110, 255, 90);
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
			anim_frame = 0;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 0;
				attack_connected = false;
				super_invuln = false;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			var _len = _tb.len;
			var _total = _len * WHIP_LOOPS;
			var _t = attack_frame mod _len;
			var _loop = attack_frame div _len;
			
			for (var k = 0; k < array_length(_tb.frames); k++)
				{
				var _e = _tb.frames[k];
				if (_t >= _e.start && _t < _e.start + _e.dur)
					{
					anim_frame = _e.f;
					
					if (_t == _e.start && !is_undefined(_e.hit))
						{
						var _h = _e.hit;
						var _row = (_loop == (WHIP_LOOPS - 1)) ? 1 : 0;
						var _final = (_row == 1 && _which[_e.f] == 3);
						
						attack_connected = false;
						var _hb = hitbox_create(_h[0], _h[1], _h[2], _h[3], _dmg[_row][_which[_e.f]], 4);
						_hb.hitlag = _final ? 10 : 4;
						_hb.hitstun = 40;
						_hb.knockback = _final ? 14 : 2;
						if (_h[4] == 1) then _hb.high = true;
						if (_h[4] == 2) then _hb.low = true;
						if (_final)
							{
							_hb.launch_speed = 16;
							_hb.knockdown = true;
							}
						obj_game.cam_shake = max(obj_game.cam_shake, _final ? 12 : 4);
						}
					break;
					}
				}
			
			attack_frame++;
			
			var _gate = _tb.frames[1].start + 6;
			if (attack_frame == _gate && !(attack_connected && attack_hit_confirmed()))
				{
				attack_phase = 2;
				attack_frame = WHIP_MISS_LAG;
				}
			else if (attack_frame >= _total)
				{
				attack_phase = 3;
				attack_frame = WHIP_END_LAG;
				anim_frame = 23;
				}
			
			hsp = lerp(hsp, 0, 0.2);
			player_move();
			}
		break;
		
		case 2:
			{
			attack_frame--;
			anim_frame = 7 - clamp(attack_frame div 4, 0, 4);
			
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
		
		case 3:
			{
			attack_frame--;
			anim_frame = 23;
			
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