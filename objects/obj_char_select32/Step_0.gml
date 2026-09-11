/// @description Selección y Asignación Directa

// --- CONTROLES P1 ---
var _p1_left   = keyboard_check_pressed(ord("A"));
var _p1_right  = keyboard_check_pressed(ord("D"));
var _p1_select = keyboard_check_pressed(ord("J")) || keyboard_check_pressed(vk_enter);
var _p1_cancel = keyboard_check_pressed(ord("K")) || keyboard_check_pressed(vk_backspace);

// --- CONTROLES P2 (SOLO FLECHAS / NUMPAD) ---
var _p2_left   = keyboard_check_pressed(vk_left);
var _p2_right  = keyboard_check_pressed(vk_right);
var _p2_select = keyboard_check_pressed(vk_numpad1) || keyboard_check_pressed(vk_space);
var _p2_cancel = keyboard_check_pressed(vk_numpad2);

// --- SELECCIÓN P1 ---
if (!p1_confirmed)
	{
	if (_p1_left)
		{
		p1_cursor--;
		if (p1_cursor < 0) p1_cursor = char_count - 1;
		}
	if (_p1_right)
		{
		p1_cursor++;
		if (p1_cursor >= char_count) p1_cursor = 0;
		}
	if (_p1_select)
		{
		p1_confirmed = true;
		global.p1_select = characters[p1_cursor].char_id; 
		}
	}
else if (_p1_cancel)
	{
	p1_confirmed = false;
	start_timer = -1;
	}

// --- SELECCIÓN P2 (MODO LOCAL) ---
if (!global.online_mode)
	{
	if (!p2_confirmed)
		{
		if (_p2_left)
			{
			p2_cursor--;
			if (p2_cursor < 0) p2_cursor = char_count - 1;
			}
		if (_p2_right)
			{
			p2_cursor++;
			if (p2_cursor >= char_count) p2_cursor = 0;
			}
		if (_p2_select)
			{
			p2_confirmed = true;
			global.p2_select = characters[p2_cursor].char_id; 
			}
		}
	else if (_p2_cancel)
		{
		p2_confirmed = false;
		start_timer = -1;
		}
	}

// --- IR A GAMEPLAY ---
if (p1_confirmed && (p2_confirmed || global.online_mode))
	{
	if (start_timer == -1) start_timer = 30;
	
	if (--start_timer <= 0)
		{
		room_goto(rm_gameplay);
		}
	}

// Salir al menú con ESC
if (keyboard_check_pressed(vk_escape))
	{
	room_goto(rm_main_menu);
	}