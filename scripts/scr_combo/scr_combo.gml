///@param {int} hits
/*
Devuelve la frase de combo para ese número de golpes, o undefined si no hay.
Va de mayor a menor: se queda con la primera cuyo mínimo se cumple.
snd = -1 significa sin sonido. Los nombres de sonido son ejemplos: usa los de tus recursos.
*/
function combo_callout(_hits)
	{
	static _table =
		[
		{ need: 10, text: "MEGA COMBO",   col: c_red,    snd: snd_mega_combo },
		{ need: 7,  text: "ULTRA COMBO",  col: c_orange, snd: snd_ultra_combo },
		{ need: 5,  text: "SUPER COMBO",  col: #FFDD00,  snd: snd_super_combo },
		{ need: 3,  text: "NOOB COMBO", col: c_white,  snd: -1 }
		];
	
	for (var i = 0; i < array_length(_table); i++)
		{
		if (_hits >= _table[i].need) then return _table[i];
		}
	return undefined;
	}

/*
Registra un golpe recibido en el combo actual. Se llama desde el jugador golpeado.
*/
function combo_register_hit()
	{
	if (!combo_active)
		{
		combo_hits = 0;       //empieza un combo nuevo
		combo_active = true;
		}
	combo_hits++;
	combo_show = COMBO_SHOW_FRAMES;
	}
	
/*
Cuanto dano hace el golpe numero _hits de un combo (nuestro): 1 y 2 al 100%, y baja 10% por golpe hasta un minimo de 40%.
Para cambiar la reduccion: el 0.1 es cuanto baja por golpe y el 0.4 es el minimo.
*/
function combo_damage_scale(_hits)
	{
	return clamp(1 - (0.1 * (_hits - 2)), 0.4, 1);
	}	