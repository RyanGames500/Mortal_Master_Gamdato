//Hover
if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
	{
	hover_time = min(++hover_time, 6);
	if (mouse_check_button_pressed(mb_left))
		{
		clicked = true;
		
		//Kick the player, then refresh the UI so it removes their UI
		ggmr_lobby_member_kick(member);
		main_menu_ui_refresh();
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

/* Copyright 2024 Springroll Games / Yosi */