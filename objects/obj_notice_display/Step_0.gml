for (var i = array_length(global.notice_queue) - 1; i >= 0; i--)
	{
	global.notice_queue[i].timer--;
	if (global.notice_queue[i].timer <= 0)
		{
		array_delete(global.notice_queue, i, 1);
		}
	}
	
	if (global.critical_overlay_active)
	{
	global.critical_overlay_timer--;
	if (global.critical_overlay_timer <= 0)
		{
		global.critical_overlay_active = false;
		}
	}