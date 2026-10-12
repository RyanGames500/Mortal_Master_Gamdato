///Temblor de camara para personajes pesados (nuestro)
//Solo afecta a los que pongan step_shake / land_shake mayor que 0 en su character_init.
//Usa el mismo obj_game.cam_shake que ya usa el knockdown.

function player_walk_shake()
	{
	if (step_shake <= 0) then return;
	
	var _prev = floor(anim_frame - anim_speed);
	var _now  = floor(anim_frame);
	
	//Pisada: cuando la animacion de caminar entra al frame 2 o al 5
	if (_now != _prev && (_now == 2 || _now == 5))
		{
		obj_game.cam_shake = max(obj_game.cam_shake, step_shake);
		}
	}

function player_land_shake()
	{
	if (land_shake <= 0) then return;
	obj_game.cam_shake = max(obj_game.cam_shake, land_shake);
	}