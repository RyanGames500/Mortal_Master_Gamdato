/*
Updates the camera coordinates.
*/
function camera_update()
	{
	if (intro_active())
		{
		if (!ggmr_session_is_in_rollback())
			{
			var _c = intro_cam(intro_t());
			var _vw = min(_c.vw, room_width);
			var _vh = _vw * 720 / global.view_w;
			var _vx = clamp(_c.cx - _vw * 0.5, 0, room_width - _vw);
			var _vy = room_height - _vh;
			camera_set_view_size(camera_index, _vw, _vh);
			camera_set_view_pos(camera_index, _vx + choose(-_c.shake, _c.shake), _vy + choose(-_c.shake, _c.shake));
			cam_x_display = _vx;
			cam_y_display = _vy;
			}
		return;
		}		
	//Get the average x and y of all players
	var _num_players = instance_number(obj_player);
	var _mean_x = 0;
	var _mean_y = 0;
	with (obj_player)
		{
		_mean_x += x;
		_mean_y += y;
		}
	_mean_x = _mean_x div _num_players;
	_mean_y = _mean_y div _num_players;
	
	//Tamano real de la vista (con el zoom aplicado) (nuestro)
	var _vw = camera_get_view_width(camera_index);
	var _vh = camera_get_view_height(camera_index);
	
	//Restrict the camera to the room boundaries
	//En y la vista queda pegada abajo: el suelo se ve igual y el extra del zoom se agrega arriba
	cam_x = clamp(_mean_x - (_vw * 0.5), 0, room_width - _vw);
	cam_y = room_height - _vh;
	
	//Don't move the camera during rollback frames
	if (!ggmr_session_is_in_rollback())
		{
		//Smoothly move the camera to the goal coordinates
		cam_x_display = lerp(cam_x_display, cam_x, 0.1);
		cam_y_display = lerp(cam_y_display, cam_y, 0.1);
		
		//Camera shake
		cam_x_display += choose(-cam_shake, cam_shake);
		cam_y_display += choose(-cam_shake, cam_shake);
		cam_shake *= 0.9;
		if (cam_shake < 1) then cam_shake = 0.0;
		
		camera_set_view_pos(camera_index, cam_x_display, cam_y_display);
		}
	}

/* Copyright 2024 Springroll Games / Yosi */