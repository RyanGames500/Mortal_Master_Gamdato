/// Reto del Nucleo (nuestro): cabina estilo "pila al frente, personaje detras".
/// Un solo obstaculo por evento: si lo rompes, el siguiente evento trae el siguiente; si pierdes, se repite.
phase = 0;				// 0 intro · 1 jugando · 2 resultado
phase_t = 0;
won = false;
end_t = 0;
shake = 0;
particles = [];
floor_y = 600;				// borde superior de la placa; la pila se apoya aqui

fill_per_press = 0.055;		// cuanto sube la barra por cada pulsacion de carga
n_booths = 1;				// 1 = arcade. VS local de 2 humanos: se pondra en 2
booth_w = (n_booths == 1) ? 600 : 500;

// Obstaculos de blando a duro. need = fuerza minima (0 a 1), secs = tiempo, decay = cuanto cae la barra por frame
mats = [
	{ name: "BARRO SECO",      need: 0.30, secs: 9,  decay: 0.0020, col: make_colour_rgb(150, 104, 66),  col2: make_colour_rgb(190, 140, 96) },
	{ name: "HUESO",           need: 0.45, secs: 9,  decay: 0.0026, col: make_colour_rgb(214, 204, 176), col2: make_colour_rgb(242, 234, 210) },
	{ name: "CHATARRA",        need: 0.60, secs: 9,  decay: 0.0032, col: make_colour_rgb(150, 82, 52),   col2: make_colour_rgb(200, 120, 72) },
	{ name: "CRISTAL MUTANTE", need: 0.78, secs: 9,  decay: 0.0038, col: make_colour_rgb(110, 90, 210),  col2: make_colour_rgb(150, 230, 240) },
	{ name: "NUCLEO",          need: 0.92, secs: 10, decay: 0.0044, col: make_colour_rgb(60, 220, 110),  col2: make_colour_rgb(210, 255, 220) }
];

// Pedazos que saltan al romper (solo visual, offline)
burst = function(_x, _y, _n, _spd, _col, _sz)
	{
	for (var _i = 0; _i < _n; _i++)
		{
		array_push(particles, [_x + random_range(-110, 110), _y + random_range(-40, 20), random_range(-_spd, _spd), random_range(-_spd * 1.5, -_spd * 0.2), 34 + irandom(28), _col, 4 + irandom(_sz)]);
		}
	};

// Crea una cabina. Usa poses de frente si existen (spr_<nombre>_tym_ready / _tym_strike); si no, el sprite de perfil
make_booth = function(_idx, _cid, _cx)
	{
	var _names = ["blocky", "blocky", "lex", "blitsen", "saori", "scar", "brad", "mayel", "danny", "mariel", "demon", "bear"];
	_cid = clamp(_cid, 1, 11);
	var _n = _names[_cid];
	var _fr = asset_get_index("spr_" + _n + "_tym_ready");
	var _fs = asset_get_index("spr_" + _n + "_tym_strike");
	var _front = sprite_exists(_fr) && sprite_exists(_fs);
	var _idle = asset_get_index("spr_" + _n + "_idle");
	var _hit = asset_get_index("spr_" + _n + "_heavy_ground");
	if (!sprite_exists(_hit)) then _hit = asset_get_index("spr_" + _n + "_medium_ground");
	if (!sprite_exists(_hit)) then _hit = _idle;
	var _scale = _front ? 6 : 4;
	return {
		idx: _idx, cx: _cx,
		front: _front, fr: _fr, fs: _fs,
		idle: _idle, hit: _hit, scale: _scale,
		foot: sprite_exists(_idle) ? (sprite_get_height(_idle) - sprite_get_yoffset(_idle)) * _scale : 0,
		bar: 0, lvl: 0, mat: 0, t_left: mats[0].secs * 60,
		state: 0,			// 0 jugando · 1 golpeando · 2 gano · 3 se acabo el tiempo
		strike: 0, power: 0, pump: 0, cracks: 0, rub: -1,
		grade: "", grade_col: c_white, flash: 0, appear: 30
	};
	};

// Dibuja un obstaculo bajo y ancho (nuestro). _fl = suelo de la pila
draw_mat = function(_kind, _x, _fl, _cracks, _ready)
	{
	var _m = mats[_kind];
	var _c = _m.col;
	var _c2 = _m.col2;
	var _dk = merge_colour(_c, c_black, 0.5);
	_x += _ready ? sin(phase_t * 0.9) * 2 : 0;
	
	switch (_kind)
		{
		case 0:		// barro: ladrillos
			for (var _r = 0; _r < 3; _r++)
				{
				var _y2 = _fl - _r * 40;
				var _y1 = _y2 - 38;
				var _p = ((_r mod 2) == 0) ? [-150, -50, 50, 150] : [-150, -100, 0, 100, 150];
				for (var _k = 0; _k < array_length(_p) - 1; _k++)
					{
					var _cc = ((_k + _r) mod 2) ? _c : _c2;
					draw_rectangle_colour(_x + _p[_k] + 2, _y1, _x + _p[_k + 1] - 2, _y2, _cc, _cc, _dk, _dk, false);
					}
				}
		break;
		
		case 1:		// hueso: huesos apilados
			for (var _r = 0; _r < 4; _r++)
				{
				var _yc = _fl - 16 - _r * 30;
				draw_rectangle_colour(_x - 125, _yc - 11, _x + 125, _yc + 11, _c2, _c2, _c, _c, false);
				draw_circle_colour(_x - 132, _yc - 7, 12, _c2, _c, false);
				draw_circle_colour(_x - 132, _yc + 7, 12, _c2, _c, false);
				draw_circle_colour(_x + 132, _yc - 7, 12, _c2, _c, false);
				draw_circle_colour(_x + 132, _yc + 7, 12, _c2, _c, false);
				}
		break;
		
		case 2:		// chatarra: placas oxidadas
			for (var _p = 0; _p < 2; _p++)
				{
				var _px = _x + (_p * 8) - 4;
				var _y2 = _fl - _p * 62;
				var _y1 = _y2 - 58;
				draw_rectangle_colour(_px - 150, _y1, _px + 150, _y2, _c2, _c2, _c, _c, false);
				draw_line_width_colour(_px - 150, _y2 - 8, _px - 80, _y1 + 8, 6, _dk, _dk);
				draw_line_width_colour(_px + 80, _y2 - 8, _px + 150, _y1 + 8, 6, _dk, _dk);
				for (var _rv = 0; _rv < 4; _rv++)
					{
					draw_circle_colour(_px + ((_rv mod 2) ? 136 : -136), (_rv < 2) ? _y1 + 10 : _y2 - 10, 5, _dk, _dk, false);
					}
				}
		break;
		
		case 3:		// cristal mutante
			var _xs = [-120, -70, -20, 30, 80, 125];
			var _hs = [70, 110, 135, 100, 125, 80];
			draw_rectangle_colour(_x - 150, _fl - 16, _x + 150, _fl, _dk, _dk, _dk, _dk, false);
			for (var _k = 0; _k < 6; _k++)
				{
				draw_triangle_colour(_x + _xs[_k] - 26, _fl - 16, _x + _xs[_k] + 26, _fl - 16, _x + _xs[_k], _fl - 16 - _hs[_k], _c, _c, _c2, false);
				}
			gpu_set_blendmode(bm_add);
			draw_set_alpha(0.14 + 0.08 * sin(phase_t * 0.12));
			draw_circle_colour(_x, _fl - 70, 120, _c2, _c2, false);
			draw_set_alpha(1);
			gpu_set_blendmode(bm_normal);
		break;
		
		case 4:		// nucleo en una jaula baja
			var _pr = 46 + sin(phase_t * 0.15) * 5;
			draw_rectangle_colour(_x - 140, _fl - 34, _x + 140, _fl, make_colour_rgb(50, 58, 70), make_colour_rgb(50, 58, 70), make_colour_rgb(24, 28, 36), make_colour_rgb(24, 28, 36), false);
			gpu_set_blendmode(bm_add);
			for (var _g = 3; _g >= 0; _g--)
				{
				draw_set_alpha(0.22 / (_g + 1));
				draw_circle_colour(_x, _fl - 82, _pr * (1 + _g * 0.45), _c, _c, false);
				}
			draw_set_alpha(1);
			gpu_set_blendmode(bm_normal);
			draw_circle_colour(_x, _fl - 82, _pr, _c2, _c, false);
			for (var _b = 0; _b < 5; _b++)
				{
				var _bx = _x - 120 + _b * 60;
				draw_rectangle_colour(_bx - 3, _fl - 128, _bx + 3, _fl - 34, make_colour_rgb(80, 92, 110), make_colour_rgb(80, 92, 110), make_colour_rgb(44, 50, 62), make_colour_rgb(44, 50, 62), false);
				}
			draw_rectangle_colour(_x - 140, _fl - 134, _x + 140, _fl - 124, make_colour_rgb(80, 92, 110), make_colour_rgb(80, 92, 110), make_colour_rgb(80, 92, 110), make_colour_rgb(80, 92, 110), false);
		break;
		}
	
	// Grietas por golpes sin fuerza
	for (var _k = 0; _k < _cracks * 3; _k++)
		{
		var _sx = _x - 110 + ((_k * 61) mod 220);
		var _sy = _fl - 30 - ((_k * 83) mod 70);
		var _dir = (_k mod 2) * 2 - 1;
		draw_line_width_colour(_sx, _sy, _sx + _dir * 18, _sy + 16, 3, c_black, c_black);
		draw_line_width_colour(_sx + _dir * 18, _sy + 16, _sx + _dir * 5, _sy + 36, 3, c_black, c_black);
		}
	};

// Escombros del ultimo obstaculo roto, a los lados de la pila (nuestro)
draw_rubble = function(_x, _fl, _kind)
	{
	if (_kind < 0) then return;
	var _m = mats[_kind];
	for (var _k = 0; _k < 12; _k++)
		{
		var _rx = _x + ((_k < 6) ? (-175 - _k * 16) : (175 + (_k - 6) * 16));
		var _rs = 12 + ((_k * 7) mod 12);
		var _rc = (_k mod 2) ? _m.col : _m.col2;
		draw_rectangle_colour(_rx, _fl - _rs - ((_k mod 3) * 6), _rx + _rs, _fl, _rc, _rc, _rc, _rc, false);
		}
	};

if (is_undefined(global.arcade))
	{
	room_goto(rm_main_menu);
	exit;
	}

// Progreso del arcade (nuestro): un solo obstaculo por evento. Avanza al siguiente solo si lo rompes
if (!variable_struct_exists(global.arcade, "tym")) then global.arcade.tym = 0;
var _lvl = clamp(global.arcade.tym, 0, array_length(mats) - 1);

booths = [make_booth(0, global.arcade.p1, 640)];
booths[0].lvl = _lvl;			// obstaculo de este evento
booths[0].mat = _lvl;			// el que se dibuja ahora
booths[0].t_left = mats[_lvl].secs * 60;