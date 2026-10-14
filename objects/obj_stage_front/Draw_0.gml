// Capas del stage que van por delante de los personajes
var _cam_x = camera_get_view_x(camera_index);
var _cam_y = camera_get_view_y(camera_index);
var _dx = _cam_x - (((480 * 6) - camera_width) / 2);

var _stage = stage_get(obj_game.stage_id);

for (var _l = 0; _l < array_length(_stage.layers); _l++)
	{
	var _layer = _stage.layers[_l];
	if (_layer.front) then stage_draw_layer(_layer, _cam_x, _cam_y, _dx, _stage.art_y);
	}