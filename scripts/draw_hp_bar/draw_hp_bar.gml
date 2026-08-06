///@param {int} x				The x position of the bar
///@param {int} y				The y position of the bar
///@param {int} width			The width of the bar
///@param {int} height			The height of the bar
///@param {int} pad				The padding used for the bar
///@param {int} hp				The player's current HP
///@param {int} hp_prev			The player's previous HP before they last got hit
///@param {int} hp_max			The player's maximum HP
///@param {int} direction		Which direction the bar goes, either 1 for right or -1 for left
/*
Draws the HP bar for a player.
*/
function draw_hp_bar(_x, _y, _width, _height, _pad, _hp, _hp_prev, _hp_max, _direction)
	{
	if (_direction == 1)
		{
		draw_set_color(c_black);
		draw_rectangle(_x, _y, _x + _width + (_pad * 2), _y + _height + (_pad * 2), false);
		draw_set_color(#AA2200);
		draw_rectangle(_x + _pad, _y + _pad, _x + _width + _pad, _y + _height + _pad, false);
		draw_set_color(c_red);
		draw_rectangle(_x + _pad, _y + _pad, _x + lerp(0, _width, _hp_prev / _hp_max) + _pad, _y + _height + _pad, false);
		if (_hp > 0)
			{
			draw_set_color(#FFDD00);
			draw_rectangle(_x + _pad, _y + _pad, _x + lerp(0, _width, _hp / _hp_max) + _pad, _y + _height + _pad, false);
			}
		}
	else if (_direction == -1)
		{
		draw_set_color(c_black);
		draw_rectangle(_x - _width - (_pad * 2), _y, _x, _y + _height + (_pad * 2), false);
		draw_set_color(#AA2200);
		draw_rectangle(_x - _width - _pad, _y + _pad, _x - _pad, _y + _height + _pad, false);
		draw_set_color(c_red);
		draw_rectangle(_x - lerp(0, _width, _hp_prev / _hp_max) - _pad, _y + _pad, _x - _pad, _y + _height + _pad, false);
		if (_hp > 0)
			{
			draw_set_color(#FFDD00);
			draw_rectangle(_x - lerp(0, _width, _hp / _hp_max) - _pad, _y + _pad, _x - _pad, _y + _height + _pad, false);
			}
		}
	}




///@param {int} x				The x position of the bar
///@param {int} y				The y position of the bar
///@param {int} width			The width of the bar
///@param {int} height			The height of the bar
///@param {int} pad				The padding used for the bar
///@param {int} meter			The player's current Meter
///@param {int} meter_max		The player's maximum Meter
///@param {int} direction		Which direction the bar goes, either 1 for right or -1 for left
/*
Draws the Meter/Super bar for a player.
*/
function draw_meter_bar(_x, _y, _width, _height, _pad, _meter, _meter_max, _direction)
	{
	if (_direction == 1)
		{
		// Fondo negro (borde/padding)
		draw_set_color(c_black);
		draw_rectangle(_x, _y, _x + _width + (_pad * 2), _y + _height + (_pad * 2), false);
		
		// Fondo rojo oscuro (barra vacía)
		draw_set_color(#550000);
		draw_rectangle(_x + _pad, _y + _pad, _x + _width + _pad, _y + _height + _pad, false);
		
		// Relleno de la barra en color Rojo Brillante
		if (_meter > 0)
			{
			draw_set_color(c_red); // O un código hex como #FF1111 si quieres un rojo específico
			draw_rectangle(_x + _pad, _y + _pad, _x + lerp(0, _width, _meter / _meter_max) + _pad, _y + _height + _pad, false);
			}
		}
	else if (_direction == -1)
		{
		// Fondo negro (borde/padding)
		draw_set_color(c_black);
		draw_rectangle(_x - _width - (_pad * 2), _y, _x, _y + _height + (_pad * 2), false);
		
		// Fondo rojo oscuro (barra vacía)
		draw_set_color(#550000);
		draw_rectangle(_x - _width - _pad, _y + _pad, _x - _pad, _y + _height + _pad, false);
		
		// Relleno de la barra en color Rojo Brillante
		if (_meter > 0)
			{
			draw_set_color(c_red);
			draw_rectangle(_x - lerp(0, _width, _meter / _meter_max) - _pad, _y + _pad, _x - _pad, _y + _height + _pad, false);
			}
		}
	}