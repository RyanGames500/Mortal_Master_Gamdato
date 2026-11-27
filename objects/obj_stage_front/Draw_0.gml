var _vw = camera_get_view_width(camera_index);
var _vh = camera_get_view_height(camera_index);
var _cam_x = camera_get_view_x(camera_index) + ((_vw - camera_width) * 0.5);
var _cam_y = camera_get_view_y(camera_index) + (_vh - camera_height);
var _dx = _cam_x - (((480 * 6) - camera_width) / 2);

var _stage = stage_get(obj_game.stage_id);

stage_npcs_draw();

for (var _l = 0; _l < array_length(_stage.layers); _l++)
	{
	var _layer = _stage.layers[_l];
	if (_layer.front) then stage_draw_layer(_layer, _cam_x, _cam_y, _dx, _stage.art_y);
	}