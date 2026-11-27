///@category Matchmaking
///@param {struct} options		Optional: { team_size, auto_accept }
///@category Matchmaking
///@param {struct} options		Optional: { team_size, auto_accept, region }
function gamdato_matchmaking_start()
	{
	var _opt = (argument_count > 0 && is_struct(argument[0])) ? argument[0] : {};
	var _team_size = variable_struct_exists(_opt, "team_size") ? clamp(real(_opt[$ "team_size"]), 1, 8) : 1;
	var _auto = variable_struct_exists(_opt, "auto_accept") ? (_opt[$ "auto_accept"] ? true : false) : false;
	
	var _region = variable_struct_exists(_opt, "region") ? string(_opt[$ "region"]) : "latam";

	if (!instance_exists(obj_matchmaking_search))
		{
		instance_create_depth(0, 0, -9999, obj_matchmaking_search);
		}

	obj_matchmaking_search.mm_team_size = _team_size;
	obj_matchmaking_search.mm_auto_accept = _auto;
	obj_matchmaking_search.mm_region = _region;

	if (instance_exists(obj_ggmr_net))
		{
		if (obj_ggmr_net.net_socket == -1)
			{
			ggmr_net_init();
			}
		gmda_matchmakingSetSocket(obj_ggmr_net.net_socket, real(obj_ggmr_net.net_port));
		}

	gmda_matchmakingJoin({ team_size: _team_size, auto_accept: _auto, region: _region });
	}