//Spectating is not fully implemented yet (WIP)
/*
//Hover
if (!disabled)
	{
	if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
		{
		hover_time = min(++hover_time, 6);
		if (mouse_check_button_pressed(mb_left))
			{
			clicked = true;
			ggmr_lobby_member_player_type_switch(member);
			ggmr_lobby_sync_members();
			}
		}
	else
		{
		hover_time = max(--hover_time, 0);
		}

	if (!mouse_check_button(mb_left))
		{
		clicked = false;
		}
	}
*/

//Text
if (ggmr_lobby_member_get(member, GGMR_LOBBY_MEMBER.client_type) == GGMR_CLIENT_TYPE.player)
	{
	text = "Player";
	}
else
	{
	text = "Spectator";
	}

/* Copyright 2024 Springroll Games / Yosi */