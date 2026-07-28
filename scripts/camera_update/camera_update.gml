/*
Updates the camera coordinates.
*/
function camera_update()
	{
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
	
	//Restrict the camera to the room boundaries
	cam_x = clamp(_mean_x - (camera_width div 2), 0, room_width - camera_width);
	cam_y = clamp(_mean_y - (camera_height div 2), 0, room_height - camera_height);
	
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