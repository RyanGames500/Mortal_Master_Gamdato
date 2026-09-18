function game_show_notice(_text, _duration = 180)
	{
	array_push(global.notice_queue, { text: _text, timer: _duration, max_timer: _duration });
	}