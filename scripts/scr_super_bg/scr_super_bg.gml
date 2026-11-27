#macro SBG_COVER		0.95
#macro SBG_FADE_IN		0.35
#macro SBG_FADE_OUT		0.15
#macro SBG_FLASH_T		3

function game_draw_super_bg()
	{
	if (!instance_exists(obj_game)) then return;
	if (obj_game.game_meta_state != GAME_META_STATE.running && obj_game.game_meta_state != GAME_META_STATE.round_restart)
		{
		sbg_a = 0;
		return;
		}
	
	var _on = false;
	var _flash = 0;
	with (obj_player)
		{
		if (super_id == 2 && (super_fx > 0 || state == PLAYER_STATE.attacking))
			{
			_on = true;
			other.sbg_col = ex_glow_color;
			
			if (super_fx > (SUPER_FX_FRAMES - SBG_FLASH_T))
				{
				_flash = (super_fx - (SUPER_FX_FRAMES - SBG_FLASH_T)) / SBG_FLASH_T;
				}
			break;
			}
		}
	
	sbg_a = lerp(sbg_a, _on ? 1 : 0, _on ? SBG_FADE_IN : SBG_FADE_OUT);
	if (sbg_a < 0.01)
		{
		sbg_a = 0;
		return;
		}
	
	var _a = sbg_a;
	var _col = sbg_col;
	var _vx = camera_get_view_x(camera_index);
	var _vy = camera_get_view_y(camera_index);
	var _w = camera_get_view_width(camera_index);
	var _h = camera_get_view_height(camera_index);
	var _cx = _vx + (_w * 0.5);
	var _cy = _vy + (_h * 0.5);
	var _seed = floor(current_time / 45);
	var _pulse = 0.85 + (0.15 * dsin(current_time * 0.4));
	
	draw_set_colour(merge_colour(c_black, _col, 0.25));
	draw_set_alpha(SBG_COVER * _a);
	draw_rectangle(_vx - 16, _vy - 16, _vx + _w + 16, _vy + _h + 16, false);
	
	gpu_set_blendmode(bm_add);
	
	draw_set_colour(_col);
	for (var _g = 0; _g < 7; _g++)
		{
		draw_set_alpha(0.12 * _a * _pulse);
		draw_circle(_cx, _cy, 80 + (_g * 80), false);
		}
	
	draw_set_alpha(0.9 * _a);
	draw_action_lines(_cx, _cy, _w, _h, 30, 60, 260, 200, _col, _seed);
	
	draw_set_alpha(0.75 * _a);
	draw_action_lines(_cx, _cy, _w, _h, 44, 22, 320, 260, c_white, _seed + 7);
	
	gpu_set_blendmode(bm_normal);
	
	if (_flash > 0)
		{
		draw_set_colour(c_white);
		draw_set_alpha(_flash);
		draw_rectangle(_vx - 16, _vy - 16, _vx + _w + 16, _vy + _h + 16, false);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}