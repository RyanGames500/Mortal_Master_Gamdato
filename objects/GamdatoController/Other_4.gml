// ROOM START

//If the netcode socket could not be opened, look for the next free port.
//Happens when two copies of the game run on the same machine
if (instance_exists(obj_ggmr_net) && obj_ggmr_net.net_socket == -1)
	{
	var _base = real(obj_ggmr_net.net_port);
	for (var _p = _base + 1; _p <= _base + 9; _p++)
		{
		ggmr_net_port_change(_p);
		if (obj_ggmr_net.net_socket != -1)
			{
			show_debug_message("[gamdato] port " + string(_base) + " taken, listening on " + string(_p));
			break;
			}
		}
	}

if (room == rm_main_menu)
	{
	gmda_matchmakingMatchEnded();
	gmda_matchmakingStatus();
	}
