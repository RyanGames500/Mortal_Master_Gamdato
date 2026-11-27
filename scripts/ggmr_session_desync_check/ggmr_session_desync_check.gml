///@category GGMR
///@param {int} absolute_frame		The current frame that was just run
function ggmr_session_desync_check()
	{
	with (obj_ggmr_session)
		{
		var _frame = argument[0];
		if (session_frames[@ ggmr_session_frame_relative(_frame)][@ GGMR_FRAME.confirmed])
			{
			if (_frame % GGMR_SESSION_DESYNC_TEST_INTERVAL == 0)
				{
				session_desync_data.value = "";
				if (session_callbacks.on_event != ggmr_callback_default)
					{
					session_desync_data.value = session_callbacks.on_event(GGMR_EVENT.desync_check);
					}
				session_desync_data.frame = _frame;
				
				ggmr_session_send_desync_data();
				return true;
				}
			}
		return false;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_desync_check was called");
	}

/* Copyright 2024 Springroll Games / Yosi */