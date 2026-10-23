/* Supers (nuestro). Activacion, pausa y efectos; la logica de cada super vive en el script de cada personaje. */
#macro SUPER_CHARGE_FRAMES		5	//pausa del rival justo antes del golpe final (60 frames = 1 segundo): menos = el golpe sale mas rapido
#macro SUPER_FREEZE_FRAMES		20	//pausa de ambos jugadores al activar un super
#macro SUPER_FX_FRAMES			20	//duracion total del efecto (incluye la pausa)
#macro SUPER_DIM_ALPHA			0.4	//que tanto se oscurece la pantalla (0 a 1)
#macro SUPER_MOTION_LENIENCY	80	//45 //frames para completar la doble media luna
#macro METER_COST_SUPER_MAX		300	//super cinematico: toda la barra

/* Doble media luna (cuarto de circulo dos veces): abajo, abajo-adelante, adelante, x2.
   El "abajo" acepta tambien las diagonales abajo-atras y abajo-adelante, para que no sea tan exacto. */
function super_motion_check()
	{
	return input_motion_check([STICK_DIR.down_any, STICK_DIR.forward_down, STICK_DIR.forward,
							   STICK_DIR.down_any, STICK_DIR.forward_down, STICK_DIR.forward], SUPER_MOTION_LENIENCY);
	}

/*
True si el personaje puede lanzar un super ahora.
Libre en el suelo, y cancela cualquier ataque que ya conecto (golpe o bloqueo), o al inicio de un ataque.
*/
function super_state_ok()
	{
	if (bbox_bottom < obj_ground.y) then return false;
	
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.walk_backward ||
		state == PLAYER_STATE.dash)
		{
		return true;
		}
	
	if (state == PLAYER_STATE.attacking)
		{
		return (state_time < 5 || attack_connected);
		}
	
	return false;
	}

/* Se llama desde el jugador que lanza el super: pausa corta para los dos y prende el efecto */
function super_activation_fx(_id)
	{
	super_id = _id;
	super_fx = SUPER_FX_FRAMES;
	ex_flash = 45;
	obj_game.cam_shake = max(obj_game.cam_shake, 5);
	
	hitlag_frame = SUPER_FREEZE_FRAMES;
	with (obj_player)
		{
		if (id != other.id)
			{
			hitlag_frame = max(hitlag_frame, SUPER_FREEZE_FRAMES);
			}
		}
	}

/*
Efecto de super: oscurece la pantalla y dibuja energia (rayos, resplandor, aro y destello)
alrededor de quien lo lanza. Se llama al final del Draw GUI de obj_game.
Solo lee variables (super_fx, super_id, ex_glow_color), no cambia nada del juego.
*/
function game_draw_super_fx()
	{
	if (!instance_exists(obj_game)) then return;
	if (obj_game.game_meta_state != GAME_META_STATE.running && obj_game.game_meta_state != GAME_META_STATE.round_restart) then return;
	
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _vx = camera_get_view_x(camera_index);
	var _vy = camera_get_view_y(camera_index);
	var _sc = _gw / camera_get_view_width(camera_index);
	
	with (obj_player)
		{
		if (super_fx <= 0) then continue;
		if (super_id == 2) then continue;	// los de 3 barras usan el fondo de game_draw_super_bg
		
		var _t = 1 - (super_fx / SUPER_FX_FRAMES);		// 0 al activar, 1 al terminar
		var _fade = 1 - _t;
		var _k = (super_id == 2) ? 1.4 : 1;				// el cinematico es mas grande
		var _u = max(1, (bbox_bottom - bbox_top) * _sc);	// alto del personaje en pantalla
		var _cx = (((bbox_left + bbox_right) * 0.5) - _vx) * _sc;
		var _cy = (((bbox_top + bbox_bottom) * 0.5) - _vy) * _sc;
		var _col = ex_glow_color;
		var _hot = merge_colour(ex_glow_color, c_white, 0.6);
		
		// 1) Oscurecer: entra rapido, se mantiene y sale suave
		draw_set_colour(c_black);
		draw_set_alpha(SUPER_DIM_ALPHA * clamp(super_fx / 10, 0, 1) * clamp((SUPER_FX_FRAMES - super_fx) / 3, 0, 1));
		draw_rectangle(0, 0, _gw, _gh, false);
		
		gpu_set_blendmode(bm_add);
		
		// 2) Rayos de luz saliendo del personaje
		draw_set_colour(_hot);
		draw_set_alpha(0.55 * _fade);
		for (var _r = 0; _r < 14; _r++)
			{
			var _ang = (_r * (360 / 14)) + (_t * 25);
			var _len = _u * lerp(1.2, 3.2, _t) * _k;
			var _w = ((_r mod 2) == 0) ? 5 : 8;
			draw_triangle(_cx, _cy,
						  _cx + lengthdir_x(_len, _ang - _w), _cy + lengthdir_y(_len, _ang - _w),
						  _cx + lengthdir_x(_len, _ang + _w), _cy + lengthdir_y(_len, _ang + _w), false);
			}
		
		// 3) Resplandor del nucleo (capas suaves)
		draw_set_colour(_col);
		for (var _g = 0; _g < 6; _g++)
			{
			draw_set_alpha(0.16 * _fade);
			draw_circle(_cx, _cy, _u * (1.4 - (_g * 0.2)) * lerp(1, 0.6, _t) * _k, false);
			}
		
		// 4) Aro grueso que se expande
		var _tt = clamp(_t * 1.5, 0, 1);
		var _rr = _u * lerp(0.3, 1.8, _tt) * _k;
		var _thick = max(3, _u * 0.07);
		draw_set_colour(_hot);
		draw_set_alpha((1 - _tt) * 0.9);
		for (var _i = 0; _i < _thick; _i++)
			{
			draw_circle(_cx, _cy, _rr + _i, true);
			}
		
		// 5) Destello blanco al activar
		if (_t < 0.2)
			{
			draw_set_colour(c_white);
			draw_set_alpha((1 - (_t / 0.2)) * 0.6);
			draw_circle(_cx, _cy, _u * 0.9 * _k, false);
			}
		
		gpu_set_blendmode(bm_normal);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}
	
/*
Linea de tiempo de un super cinematico (nuestro).
super_ev crea un evento: en el frame _t de la secuencia, pone el sprite y frame de la pose,
opcionalmente da un impulso hacia adelante (_mv) y opcionalmente lanza un golpe (_hit).
_hit = [x_offset, y_offset, ancho, alto, daño, lanzamiento, empuje (opcional, por defecto 3)]  (lanzamiento 0 = no lanza)
Regla: dos golpes deben estar separados por 5 frames o mas.
*/
function super_ev(_t, _spr, _f, _mv = 0, _hit = undefined)
	{
	return { t: _t, spr: _spr, f: _f, mv: _mv, hit: _hit };
	}

//Ejecuta los eventos de la linea de tiempo que caen en el frame _t. Lo llama el jugador que lanza el super.
//_hit = [x, y, ancho, alto, daño, lanzamiento, empuje (opcional, por defecto 3)]
function super_timeline_run(_tl, _t)
	{
	for (var _i = 0; _i < array_length(_tl); _i++)
		{
		var _e = _tl[_i];
		if (_e.t != _t) then continue;
		
		anim_sprite = _e.spr;
		anim_frame = _e.f;
		if (_e.mv != 0) then hsp = _e.mv * facing;
		
		if (!is_undefined(_e.hit))
			{
			var _h = _e.hit;
			attack_connected = false;
			var _hb = hitbox_create(_h[0], _h[1], _h[2], _h[3], _h[4], 4);
			_hb.hitlag = 4;
			_hb.knockback = (array_length(_h) > 6) ? _h[6] : 3;
			_hb.hitstun = 60;
			if (_h[5] > 0) then _hb.launch_speed = _h[5];
			obj_game.cam_shake = max(obj_game.cam_shake, 4);
			}
		}
	}