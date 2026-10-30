// scr_view_fit (nuestro): ajusta la vista a la pantalla y la aleja un poco. Solo dibujo.
global.view_w = 1280;
global.cam_zoom = 1.15;		// 1.0 = como antes, 1.15 = 15% mas lejos, 1.3 = 30% mas lejos
global.cam_zoom_eff = 1.0;	// zoom realmente aplicado (nunca pasa del ancho del cuarto)

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
	// El zoom nunca hace la vista mas ancha que el cuarto
	var _z = max(1, min(global.cam_zoom, room_width / _w));
	global.cam_zoom_eff = _z;
	// La vista del mundo es mas grande (se ve mas lejos); la pantalla y el HUD siguen en _w x 720
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

// Margen extra (a cada lado) que la vista ve de mas respecto a camera_width
function view_fit_extra()
	{
	return max(0, (camera_get_view_width(camera_index) - camera_width) * 0.5);
	}

// Esquina de una ventana "virtual" de 1280x720, centrada en x y pegada abajo (para el acido)
function view_fit_vx()
	{
	return camera_get_view_x(camera_index) + ((camera_get_view_width(camera_index) - 1280) * 0.5);
	}
function view_fit_vy()
	{
	return camera_get_view_y(camera_index) + (camera_get_view_height(camera_index) - 720);
	}