function check_unlock_conditions()
	{
	if (obj_game.p1_select == 2 && obj_game.p2_wins == 0)
		{
		character_unlock("BRAD");
		}
		
	if (obj_game.p1_select == 1)
		{
		character_unlock("SAORI");
		}
		
	}
	
	
	