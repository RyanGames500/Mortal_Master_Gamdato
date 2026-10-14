//Custom draw script
if (custom_draw != -1 && script_exists(custom_draw))
	{
	script_execute(custom_draw);
	}

if (global.show_hitboxes) then draw_self();

/* Copyright 2024 Springroll Games / Yosi */