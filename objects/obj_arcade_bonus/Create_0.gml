phase = 0;				// 0 intro · 1 jugando · 2 resultado
phase_t = 0;
t_total = 60 * 14;			// 14 segundos aqui ajusto la dificultad
t_left = t_total;
lay = 0;				// capa actual: 0 madera · 1 piedra · 2 hierro
hp_max = [100, 160, 230];		// vida de cada capa 
hp = hp_max[0];
gpos = 0.1;				// posición del marcador (0 a 1)
gdir = 1;
cool = 0;
shake = 0;
hit_flash = 0;
last_txt = "";
last_col = c_white;
last_txt_t = 0;
won = false;
particles = [];
part_cols = [make_colour_rgb(150, 100, 56), make_colour_rgb(150, 150, 160), make_colour_rgb(110, 125, 150)];

burst = function(_n, _spd)
	{
	for (var _i = 0; _i < _n; _i++)
		{
		array_push(particles, [880 + random_range(-60, 60), 250 + random(260), random_range(-_spd, _spd * 0.4), random_range(-_spd, 0), 30 + irandom(25), part_cols[min(lay, 2)], 3 + irandom(5)]);
		}
	};

// Sprites del personaje elegido (nuestro)
var _cid = is_undefined(global.arcade) ? 1 : global.arcade.p1;
var _names = ["blocky", "blocky", "lex", "blitsen", "saori", "scar", "brad", "mayel", "danny", "mariel", "demon", "bear"];
hero_idle = asset_get_index("spr_" + _names[_cid] + "_idle");
hero_hit = asset_get_index((_cid == 1) ? "spr_blocky_light_ground2" : ("spr_" + _names[_cid] + "_medium_ground"));
hero_scale = 3;
hero_foot = sprite_exists(hero_idle) ? (sprite_get_height(hero_idle) - sprite_get_yoffset(hero_idle)) * hero_scale : 0;

if (is_undefined(global.arcade)) then room_goto(rm_main_menu);