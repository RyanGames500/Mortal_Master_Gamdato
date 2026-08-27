function draw_hp_bar(_x, _y, _width, _height, _pad, _hp, _hp_prev, _hp_max, _direction)
	{
	// Asegurar que el máximo no sea 0 para evitar división por cero
	if (_hp_max <= 0) _hp_max = 1;
	
	var _ratio = clamp(_hp / _hp_max, 0, 1);
	var _ratio_prev = clamp(_hp_prev / _hp_max, 0, 1);

	if (_direction == 1)
		{
		// === P2 (Derecha) ===
		// 1. Fondo borde negro
		draw_set_color(c_black);
		draw_rectangle(_x, _y, _x + _width + (_pad * 2), _y + _height + (_pad * 2), false);
		
		// 2. Fondo barra vacía (Rojo Oscuro)
		draw_set_color(#AA2200);
		draw_rectangle(_x + _pad, _y + _pad, _x + _width + _pad, _y + _height + _pad, false);
		
		// 3. Daño retrasado / previo (Rojo Claro)
		draw_set_color(c_red);
		draw_rectangle(_x + _pad, _y + _pad, _x + _pad + (_width * _ratio_prev), _y + _height + _pad, false);
		
		// 4. Vida actual (Verde) - Dibuja encima para mostrar la vida real
		if (_hp > 0)
			{
			draw_set_color(c_green);
			draw_rectangle(_x + _pad, _y + _pad, _x + _pad + (_width * _ratio), _y + _height + _pad, false);
			}
		}
	else if (_direction == -1)
		{
		// === P1 (Izquierda) ===
		// 1. Fondo borde negro
		draw_set_color(c_black);
		draw_rectangle(_x - _width - (_pad * 2), _y, _x, _y + _height + (_pad * 2), false);
		
		// 2. Fondo barra vacía (Rojo Oscuro)
		draw_set_color(#AA2200);
		draw_rectangle(_x - _width - _pad, _y + _pad, _x - _pad, _y + _height + _pad, false);
		
		// 3. Daño retrasado / previo (Rojo Claro)
		draw_set_color(c_red);
		draw_rectangle(_x - _pad - (_width * _ratio_prev), _y + _pad, _x - _pad, _y + _height + _pad, false);
		
		// 4. Vida actual (Verde) - Dibuja encima anclado al centro (_x - _pad)
		if (_hp > 0)
			{
			draw_set_color(c_green);
			draw_rectangle(_x - _pad - (_width * _ratio), _y + _pad, _x - _pad, _y + _height + _pad, false);
			}
		}
	}


function draw_meter_bar(_x, _y, _width, _height, _pad, _meter, _meter_max, _direction)
	{
	if (_meter_max <= 0) _meter_max = 1;
	var _ratio = clamp(_meter / _meter_max, 0, 1);

	if (_direction == 1)
		{
		// P2: Hacia la derecha
		draw_set_color(c_black);
		draw_rectangle(_x, _y, _x + _width + (_pad * 2), _y + _height + (_pad * 2), false);
		
		draw_set_color(#550000);
		draw_rectangle(_x + _pad, _y + _pad, _x + _width + _pad, _y + _height + _pad, false);
		
		if (_meter > 0)
			{
			draw_set_color(#FF1111);
			draw_rectangle(_x + _pad, _y + _pad, _x + _pad + (_width * _ratio), _y + _height + _pad, false);
			}
		}
	else if (_direction == -1)
		{
		// P1: Hacia la izquierda
		draw_set_color(c_black);
		draw_rectangle(_x - _width - (_pad * 2), _y, _x, _y + _height + (_pad * 2), false);
		
		draw_set_color(#550000);
		draw_rectangle(_x - _width - _pad, _y + _pad, _x - _pad, _y + _height + _pad, false);
		
		if (_meter > 0)
			{
			draw_set_color(#FF1111);
			draw_rectangle(_x - _pad - (_width * _ratio), _y + _pad, _x - _pad, _y + _height + _pad, false);
			}
		}
	}