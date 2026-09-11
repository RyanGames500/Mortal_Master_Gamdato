///@description Cancel Matchmaking

//Same path as the LEAVE QUEUE button. In "starting" it can no longer be cancelled
if (state != "fade_out" && state != "starting")
	{
	leave_search();
	}
