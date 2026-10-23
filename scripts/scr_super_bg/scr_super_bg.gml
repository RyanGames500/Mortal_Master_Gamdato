/* Fondo de los supers de 3 barras, estilo juegos de pelea clasicos (nuestro).
   Mientras dura TODO el super el escenario se tapa con un fondo de color oscuro con lineas de velocidad,
   y cuando el super termina vuelve el escenario. Los personajes se quedan encima, normales.
   El efecto es ESTATICO: el centro es el centro de la pantalla, no sigue a nadie.
   Se dibuja DETRAS de los personajes, desde obj_background_manager (Draw).
   Solo visual: lee super_id, state, super_fx y ex_glow_color, no cambia nada del juego. */
#macro SBG_COVER		0.95	//que tanto tapa el escenario (0 a 1)
#macro SBG_FADE_IN		0.35	//que tan rapido entra el fondo (0 a 1, mas grande = mas rapido)
#macro SBG_FADE_OUT		0.15	//que tan rapido se va cuando termina el super
#macro SBG_FLASH_T		3		//frames del destello blanco al activar

function game_draw_super_bg()
	{
	if (!instance_exists(obj_game)) then return;
	if (obj_game.game_meta_state != GAME_META_STATE.running && obj_game.game_meta_state != GAME_META_STATE.round_restart)
		{
		sbg_a = 0;
		return;
		}
	
	// hay un super de 3 barras activo: el fondo dura mientras siga atacando
	var _on = false;
	var _flash = 0;
	with (obj_player)
		{
		if (super_id == 2 && (super_fx > 0 || state == PLAYER_STATE.attacking))
			{
			_on = true;
			other.sbg_col = ex_glow_color;
			
			// destello blanco solo en los primeros frames
			if (super_fx > (SUPER_FX_FRAMES - SBG_FLASH_T))
				{
				_flash = (super_fx - (SUPER_FX_FRAMES - SBG_FLASH_T)) / SBG_FLASH_T;
				}
			break;
			}
		}
	
	// entra rapido y sale suave (animacion solo visual)
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
	var _w = camera_width;
	var _h = camera_height;
	var _cx = _vx + (_w * 0.5);					// centro FIJO de la pantalla
	var _cy = _vy + (_h * 0.5);
	var _seed = floor(current_time / 45);		// las lineas parpadean
	var _pulse = 0.85 + (0.15 * dsin(current_time * 0.4));
	
	// 1) el escenario se tapa con un fondo oscuro con el tinte del super
	draw_set_colour(merge_colour(c_black, _col, 0.25));
	draw_set_alpha(SBG_COVER * _a);
	draw_rectangle(_vx - 16, _vy - 16, _vx + _w + 16, _vy + _h + 16, false);
	
	gpu_set_blendmode(bm_add);
	
	// 2) resplandor en el centro de la pantalla
	draw_set_colour(_col);
	for (var _g = 0; _g < 7; _g++)
		{
		draw_set_alpha(0.12 * _a * _pulse);
		draw_circle(_cx, _cy, 80 + (_g * 80), false);
		}
	
	// 3) lineas de velocidad gruesas del color del super (la funcion que ya trae el engine)
	draw_set_alpha(0.9 * _a);
	draw_action_lines(_cx, _cy, _w, _h, 30, 60, 260, 200, _col, _seed);
	
	// 4) lineas finas blancas por encima
	draw_set_alpha(0.75 * _a);
	draw_action_lines(_cx, _cy, _w, _h, 44, 22, 320, 260, c_white, _seed + 7);
	
	gpu_set_blendmode(bm_normal);
	
	// 5) destello blanco al activar
	if (_flash > 0)
		{
		draw_set_colour(c_white);
		draw_set_alpha(_flash);
		draw_rectangle(_vx - 16, _vy - 16, _vx + _w + 16, _vy + _h + 16, false);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}