///@category GGMR
///@param {int} [relative_frame]		The relative frame to predict inputs for
function ggmr_session_input_predict_local_mode()
	{
	with (obj_ggmr_session) 
		{
		var _relative_frame = argument_count > 0 ? argument[0] : GGMR_RELATIVE_FRAME;
		var _absolute_frame = ggmr_session_frame_absolute(_relative_frame);
	
		for (var i = 0; i < session_number_of_clients; i++) 
			{
			if (!session_frames[@ _relative_frame][@ GGMR_FRAME.received][@ i]) 
				{
				if (session_input_prediction_type == GGMR_PREDICTION_TYPE.template)	
					{
					} 
				else if (session_input_prediction_type == GGMR_PREDICTION_TYPE.copy) 
					{
					var _last_confirmed_frame = ggmr_session_frame_absolute(session_last_confirmed_frame);
					var _prev = ggmr_session_input_buffer_get(i, _last_confirmed_frame);
					var _current = ggmr_session_input_buffer_get(i, _absolute_frame);
				
					if (_prev != _current)
						{
						buffer_copy(_prev, 0, session_input_template_size, _current, 0);
						ggmr_log("Predicted inputs for frame ", _absolute_frame, " from frame ", _last_confirmed_frame);
						}
					
					session_frames[@ _relative_frame][@ GGMR_FRAME.times_ran] = 0;
					}
				}
			}
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_input_predict_local_mode was called");
	}

/* Copyright 2024 Springroll Games / Yosi */