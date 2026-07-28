///@category Gamdato
///@param {string} text		Label of the menu button that was pressed
///@return {bool}			true if Gamdato handled it and the menu should ignore it
/*
Gamdato's only hook into the game menu. main_menu_button_script calls it first
and bails out if it returns true.
*/
function gamdato_menu_button(_text)
	{
	//With the overlay open, the menu takes no clicks
	if (instance_exists(obj_matchmaking_search))
		{
		return true;
		}

	if (_text == "Set Name")
		{
		//Renames the account. The lobby updates once the server accepts
		var _name = get_string("Your Name:", gmda_getPlayername());
		if (_name != "")
			{
			gmda_setNewname(_name);
			}
		return true;
		}

	if (_text == "AUTO MATCHMAKING")
		{
		//Only reset the lobby when there is no search and no live match
		var _mm_st = gmda_matchmakingState();
		if (!_mm_st.in_queue && !_mm_st.found)
			{
			ggmr_lobby_reset();
			}

		//1v1 in the global pool, auto-confirming. If we were already queued this
		//just reopens the overlay
		gamdato_matchmaking_start({ auto_accept: true });
		return true;
		}

	return false;
	}
