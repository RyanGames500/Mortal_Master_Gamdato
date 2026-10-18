phase_t = 0;
art = asset_get_index("spr_arcade_map");	// tu arte del mapa (opcional): si no existe, se dibuja uno provisional
mode = 0;							// 0 siguiente pelea · 1 game over · 2 victoria · 3 continuar
travel_from = -2;
travel_frames = 0;

if (is_undefined(global.arcade))
	{
	room_goto(rm_main_menu);
	}
else
	{
	var _a = global.arcade;
	if (_a.done) then mode = 2;
	else if (_a.lost) then mode = (_a.continues < 0) ? 1 : 3;
	else if (!is_undefined(_a.offer)) then mode = 5;
	else if (_a.bonus) then mode = 4;
	travel_from = _a.travel;
	_a.travel = -2;
	travel_frames = (travel_from == -2) ? 0 : 60;
	}