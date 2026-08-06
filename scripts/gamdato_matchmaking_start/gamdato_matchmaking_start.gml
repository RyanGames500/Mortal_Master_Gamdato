///@category Matchmaking
///@param {struct} options		Optional: { team_size, auto_accept }
/*
Joins the queue and opens the search overlay.

  team_size    players per team. Default 1 (1v1)
  auto_accept  true = confirms the match by itself, with no accept screen

This example uses no regions or modes: it goes to the global pool.
*/
function gamdato_matchmaking_start()
	{
	var _opt = (argument_count > 0 && is_struct(argument[0])) ? argument[0] : {};
	var _team_size = variable_struct_exists(_opt, "team_size") ? clamp(real(_opt[$ "team_size"]), 1, 8) : 1;
	var _auto = variable_struct_exists(_opt, "auto_accept") ? (_opt[$ "auto_accept"] ? true : false) : false;

	if (!instance_exists(obj_matchmaking_search))
		{
		instance_create_depth(0, 0, -9999, obj_matchmaking_search);
		}

	obj_matchmaking_search.mm_team_size = _team_size;
	obj_matchmaking_search.mm_auto_accept = _auto;

	// Aseguramos que GGMR tenga un socket valido creado antes de entregarselo a GAMDATO
	if (instance_exists(obj_ggmr_net))
		{
		if (obj_ggmr_net.net_socket == -1)
			{
			ggmr_net_init(); // O la funcion de inicializar la red de GGMR en tu motor
			}
		gmda_matchmakingSetSocket(obj_ggmr_net.net_socket, real(obj_ggmr_net.net_port));
		}

	gmda_matchmakingJoin({ team_size: _team_size, auto_accept: _auto });
	}
