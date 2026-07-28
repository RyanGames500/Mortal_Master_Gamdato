//Hover
if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
	{
	hover_time = min(++hover_time, 6);
	
	//Clicking
	if (mouse_check_button_pressed(mb_left))
		{
		clicked = true;
		main_menu_button_script();
		}
	}
else
	{
	hover_time = max(--hover_time, 0);
	}

//Reset the click variable after the player releases the button
if (!mouse_check_button(mb_left))
	{
	clicked = false;
	}

/* Copyright 2024 Springroll Games / Yosi */