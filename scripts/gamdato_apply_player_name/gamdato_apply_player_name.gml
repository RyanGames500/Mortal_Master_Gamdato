///@category Gamdato
///@param {string} name		Nombre de la cuenta, normalmente gmda_getPlayername()
///@return {bool}			false si el nombre venia vacio
/*
rename using gamdato too
*/
function gamdato_apply_player_name(_name)
	{
	_name = string(_name);
	if (_name == "")
		{
		return false;
		}

	global.online_name = _name;

	if (instance_exists(obj_ggmr_lobby))
		{
		obj_ggmr_lobby.lobby_member_name = _name;
		ggmr_lobby_member_set(obj_ggmr_lobby.lobby_member_number, GGMR_LOBBY_MEMBER.name, _name);
		}

	if (instance_exists(obj_main_menu))
		{
		main_menu_ui_refresh();
		}

	return true;
	}
