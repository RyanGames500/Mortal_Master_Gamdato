//Quieta mientras el juego está en pausa
if (obj_game.game_paused) then exit;

//Espera el congelado del golpe y sale disparada justo cuando el rival arranca
if (delay > 0)
	{
	delay--;
	exit;
	}

var _alive = 0;
for (var i = 0; i < array_length(particles); i++)
	{
	var _p = particles[i];
	if (_p.life <= 0) then continue;
	_p.life--;
	_alive++;
	
	if (!_p.landed)
		{
		_p.vsp += 0.7;
		_p.hsp *= 0.98;
		_p.x += _p.hsp;
		_p.y += _p.vsp;
		if (_p.y >= obj_ground.y)
			{
			_p.y = obj_ground.y;
			_p.landed = true;
			}
		}
	}

if (_alive == 0) then instance_destroy();