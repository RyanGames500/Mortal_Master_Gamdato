#macro BLOOD_SIZE 2   // tamaño de las gotas: 1 = chico, 2 = grande, 3 = muy grande

///@param {real} min
///@param {real} max
/*
Número "aleatorio" propio para efectos visuales. Sale de un seed que blood_spray fija
a partir del frame y la posición del golpe, así que el patrón se repite igual en replays
y es el mismo en los dos jugadores. No usa el generador global del juego.
*/
function blood_rand(_min, _max)
	{
	global.blood_seed = (global.blood_seed * 16807) mod 2147483647;
	return _min + (global.blood_seed / 2147483647) * (_max - _min);
	}

///@param {real} x
///@param {real} y
///@param {real} dir          1 o -1: hacia dónde sale la sangre
///@param {int} amount        cantidad de gotas
///@param {real} hpower       fuerza horizontal
///@param {real} vpower       fuerza hacia arriba
///@param {int} delay         frames de espera antes de salir (el hitlag)
/*
Crea una ráfaga de sangre hecha por código. Es solo visual: no es parte del estado del juego.
*/
function blood_spray(_x, _y, _dir, _amount, _hpower, _vpower, _delay)
	{
	//Durante un rollback no se crea nada, para que no se duplique la sangre
	if (ggmr_session_is_in_rollback()) then return;
	
	//Seed determinista: depende solo del frame y del lugar del golpe
	global.blood_seed = max(1, abs(obj_game.game_frame * 7919 + floor(_x) * 31 + floor(_y) * 17 + _amount * 13) mod 2147483646);
	
	var _blood = instance_create_layer(_x, _y, "VFX_Layer", obj_blood);
	_blood.delay = _delay;
	for (var i = 0; i < _amount; i++)
		{
		_blood.particles[array_length(_blood.particles)] =
			{
			x : _x + blood_rand(-6, 6),
			y : _y + blood_rand(-6, 6),
			hsp : _dir * blood_rand(1, 7) * _hpower,
			vsp : -blood_rand(2, 8) * _vpower,
			size : BLOOD_SIZE * (4 + 2 * floor(blood_rand(0, 3))),   // 8, 12 o 16 con BLOOD_SIZE 2
			life : floor(blood_rand(30, 55)),
			landed : false
			};
		}
	}