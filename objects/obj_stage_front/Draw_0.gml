// Capas del stage que van por delante de los personajes
// Cámara virtual sin zoom, calculada desde el centro de la vista (igual que en obj_background_manager)
var _vw = camera_get_view_width(camera_index);
var _vh = camera_get_view_height(camera_index);
var _cam_x = camera_get_view_x(camera_index) + ((_vw - camera_width) * 0.5);
var _cam_y = camera_get_view_y(camera_index) + ((_vh - camera_height) * 0.5);
var _dx = _cam_x - (((480 * 6) - camera_width) / 2);

var _stage = stage_get(obj_game.stage_id);

// Personajes del escenario: por encima de los luchadores (pero detrás de las capas frontales)
stage_npcs_draw();

for (var _l = 0; _l < array_length(_stage.layers); _l++)
	{
	var _layer = _stage.layers[_l];
	if (_layer.front) then stage_draw_layer(_layer, _cam_x, _cam_y, _dx, _stage.art_y);
	}