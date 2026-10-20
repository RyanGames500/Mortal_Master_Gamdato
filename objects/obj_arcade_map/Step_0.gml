pad_menu_pump(2);

if (is_undefined(global.arcade)) then exit;
phase_t++;

if (keyboard_check_pressed(vk_escape))
	{
	global.arcade_mode = 0;
	global.arcade = undefined;
	room_goto(rm_main_menu);
	exit;
	}

var _ok = keyboard_check_pressed(ord("J")) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)
	|| mouse_check_button_pressed(mb_left) || device_mouse_check_button_pressed(0, mb_left);

if (_ok && phase_t > travel_frames + 15)
	{
	if (mode == 0 || mode == 3)
		{
		global.arcade.lost = false;
		global.replay_mode = false;
		global.online_mode = false;
		room_goto(rm_gameplay);
		}
	else if (mode == 5)
		{
		global.arcade.side = global.arcade.offer;
		global.arcade.offer = undefined;
		global.replay_mode = false;
		global.online_mode = false;
		room_goto(rm_gameplay);
		}
	else if (mode == 4)
		{
		global.arcade.bonus = false;
		room_goto(rm_arcade_bonus);
		}
	else
		{
		// mode 2 = victoria: aquí puedes desbloquear personajes, por ejemplo character_unlock("...");
		global.arcade_mode = 0;
		global.arcade = undefined;
		room_goto(rm_main_menu);
		}
	}