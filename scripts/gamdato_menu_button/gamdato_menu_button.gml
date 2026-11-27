///@category Gamdato
///@param {string} text		Label of the menu button that was pressed
///@return {bool}			true if Gamdato handled it and the menu should ignore it
function gamdato_menu_button(_text)
	{
	if (instance_exists(obj_matchmaking_search))
		{
		return true;
		}

	if (_text == "Set Name")
		{
		var _name = get_string("Your Name:", gmda_getPlayername());
		if (_name != "")
			{
			gmda_setNewname(_name);
			}
		return true;
		}

	if (_text == "AUTO MATCHMAKING")
		{
		var _mm_st = gmda_matchmakingState();
		if (!_mm_st.in_queue && !_mm_st.found)
			{
			ggmr_lobby_reset();
			}

		gamdato_matchmaking_start({ auto_accept: true });
		return true;
		}

	return false;
	}
