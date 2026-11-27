global.view_w = 1280;
global.cam_zoom = 1.15;
global.cam_zoom_eff = 1.0;

function view_fit_target_width()
	{
	var _ww = window_get_width();
	var _wh = window_get_height();
	if (_ww <= 0 || _wh <= 0) then return 1280;
	var _aspect = clamp(_ww / _wh, 16 / 9, 21 / 9);
	return 2 * round(720 * _aspect / 2);
	}

function view_fit_apply(_w)
	{
	global.view_w = _w;
	var _z = max(1, min(global.cam_zoom, room_width / _w));
	global.cam_zoom_eff = _z;
	camera_set_view_size(view_camera[0], _w * _z, 720 * _z);
	view_wport[0] = _w;
	view_hport[0] = 720;
	surface_resize(application_surface, _w, 720);
	display_set_gui_size(_w, 720);
	}

function view_fit_update()
	{
	var _w = view_fit_target_width();
	if (_w != global.view_w) then view_fit_apply(_w);
	}

function view_fit_reset()
	{
	global.view_w = 1280;
	global.cam_zoom_eff = 1.0;
	surface_resize(application_surface, 1280, 720);
	display_set_gui_size(1280, 720);
	}

function view_fit_extra()
	{
	return max(0, (camera_get_view_width(camera_index) - camera_width) * 0.5);
	}

function view_fit_vx()
	{
	return camera_get_view_x(camera_index) + ((camera_get_view_width(camera_index) - 1280) * 0.5);
	}
function view_fit_vy()
	{
	return camera_get_view_y(camera_index) + (camera_get_view_height(camera_index) - 720);
	}