#macro STAGE_COUNT	3		// cantidad de stages que existen en stage_get
/*
Crea una capa de stage con valores por defecto.
parallax: cuánto se mueve con la cámara (0 = fija al mundo)
y_off: desplazamiento vertical en pixeles del arte original
tile: repetir en X para cubrir el escenario
mirror: voltear una de cada dos copias (evita costura)
wave: ondulación suave (ácido)
acid_fx: justo después de esta capa se dibuja el cuerpo hundiéndose y la salpicadura
scale: escala a la que se dibuja la capa (los personajes usan 6)
front: true = se dibuja por delante de los personajes (lo hace obj_stage_front)
*/
function stage_layer(_sprite, _parallax = 0, _y_off = 0, _tile = false, _mirror = false, _wave = false, _acid_fx = false, _scale = 6, _front = false)
	{
	return {
		sprite: _sprite,
		parallax: _parallax,
		y_off: _y_off,
		tile: _tile,
		mirror: _mirror,
		wave: _wave,
		acid_fx: _acid_fx,
		scale: _scale,
		front: _front,
		};
	}

/*
Definición de cada stage. Agregar un stage = agregar un case.
ground_y: cuánto se mueve el piso respecto al obj_ground del room (negativo = sube a los personajes)
art_y: cuánto se baja (positivo) o se sube (negativo) todo el arte del stage, en pixeles de pantalla
*/
function stage_get(_id)
	{
	switch (_id)
		{
		case 0: // Toxi City
			return {
				name: "Toxi City",
				has_acid: true,
				ground_y: 0,
				art_y: 0,
				layers: [
					stage_layer(spr_stage1_sky, 0.30),
					stage_layer(spr_stage1_skyline, 0.12),
					stage_layer(spr_stage1_ground),
					stage_layer(spr_stage1_acid, 0, 0, false, false, true, true),
					stage_layer(spr_stage1_floor),
					],
				};
		
		case 1: // Entrada del laboratorio
			return {
				name: "Entrada del laboratorio",
				has_acid: false,
				ground_y: -90,
				art_y: 80,
				layers: [
					stage_layer(spr_stage2_back, 0.10, 16, true, true, false, false, 5),
					stage_layer(spr_stage2_pipes, 0.10, 16, true, true, false, false, 5),
					stage_layer(spr_stage2_dust, 0.15, 16, true, true, false, false, 5, true),
					],
				};
		
		case 2: // Sala de control del laboratorio (nombre nuestro, cámbialo si quieres)
			return {
				name: "Sala de control",
				has_acid: false,
				ground_y: -40,
				art_y: 80,
				layers: [
					stage_layer(spr_stage3_fondo0, 0.05, 0, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo1, 0.10, 0, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo3, 0.10, 0, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo2, 0.10, 0, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo4, 0.10, 64, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo5, 0.15, 20, true, true, false, false, 5, true),
					stage_layer(spr_stage3_fondo6, 0.15, -31, true, true, false, false, 5, true),
					],
				};
		
		default:
			return stage_get(0);
		}
	}

/*
Dibuja una capa de stage. Si tile = true la repite en X para cubrir lo que ve la cámara.
_art_y: desplazamiento vertical de todo el stage (viene de stage_get).
Los sprites deben tener el origen arriba a la izquierda, igual que los del stage 1.
*/
function stage_draw_layer(_layer, _cam_x, _cam_y, _dx, _art_y)
	{
	var _s = _layer.scale;
	var _spr = _layer.sprite;
	var _w = sprite_get_width(_spr) * _s;
	var _h = sprite_get_height(_spr) * _s;
	
	// Alineado por abajo: con arte de 216 a escala 6 da cam_y - 500, igual que antes
	var _y = _cam_y + 796 - _h + (_layer.y_off * _s) + _art_y;
	if (_layer.wave) then _y += round(sin(current_time * 0.0025) * 3);
	
	var _x0 = _dx * _layer.parallax;
	
	if (!_layer.tile)
		{
		draw_sprite_ext(_spr, 0, _x0, _y, _s, _s, 0, c_white, 1.0);
		return;
		}
	
	var _first = floor((_cam_x - _x0) / _w);
	var _last = floor((_cam_x + camera_width - _x0) / _w);
	for (var _i = _first; _i <= _last; _i++)
		{
		if (_layer.mirror && (abs(_i) mod 2) == 1)
			{
			draw_sprite_ext(_spr, 0, _x0 + ((_i + 1) * _w), _y, -_s, _s, 0, c_white, 1.0);
			}
		else
			{
			draw_sprite_ext(_spr, 0, _x0 + (_i * _w), _y, _s, _s, 0, c_white, 1.0);
			}
		}
	}
	
/*
Aplica lo que depende del stage actual: si hay ácido y la altura del piso.
Se llama al cargar un estado, al arrancar la partida y cada Begin Step del piso.
*/
function stage_apply()
	{
	var _stage = stage_get(obj_game.stage_id);
	obj_game.stage_has_acid = _stage.has_acid;
	if (instance_exists(obj_ground)) then obj_ground.y = obj_ground.base_y + _stage.ground_y;
	}
	
	

/*
Dibuja la selección de escenario sobre el selector de personajes.
Se llama desde el Draw GUI de obj_game. Es un diseño simple: cámbialo por el tuyo.
*/
function game_draw_stage_select()
	{
	if (obj_game.game_meta_state != GAME_META_STATE.char_select) then return;
	if (obj_game.stage_step == 0) then return;
	
	var _w = display_get_gui_width();
	var _h = display_get_gui_height();
	var _chosen = (obj_game.stage_step == 2);
	var _stage = stage_get(_chosen ? obj_game.stage_id : obj_game.stage_cursor);
	
	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _w, _h, false);
	draw_set_alpha(1);
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(_w / 2, _h * 0.25, global.online_mode ? "EL JUGADOR 1 ELIGE EL ESCENARIO" : "ELIGE EL ESCENARIO");
	draw_text(_w / 2, _h / 2, _chosen ? _stage.name : ("<   " + _stage.name + "   >"));
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	}
	
	/*
Deja la partida lista para empezar: aplica el stage, crea a los jugadores y pasa al estado starting.
La usan el selector de personajes y el arranque de un replay, para que los dos dejen el juego idéntico.
Se llama dentro de obj_game.
*/
function game_match_setup()
	{
	stage_apply();
	game_players_spawn();
	game_meta_state = GAME_META_STATE.starting;
	}


/*
Música de cada stage: sonido y puntos de loop en segundos.
loop_start / loop_end alimentan music_intro_pos / music_loop_pos de obj_stage_manager.
Agregar música a un stage nuevo = agregar un case (el mismo número que en stage_get).
*/
function stage_music_get(_id)
	{
	switch (_id)
		{
		case 0: // Toxi City
			return { sound: snd_toxi_city, loop_start: 10.5, loop_end: 90.0 };
		
		case 1: // Entrada del laboratorio
			return { sound: snd_entrada_laboratorio, loop_start: 10.5, loop_end: 90.0 };
		
		case 2: // Sala de control: cambia snd_toxi_city por tu pista y ajusta los dos tiempos
			return { sound: snd_toxi_city, loop_start: 10.5, loop_end: 90.0 };
		
		default:
			return stage_music_get(0);
		}
	}