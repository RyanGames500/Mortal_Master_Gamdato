//Game state loading
if (obj_game.game_state_is_loading) then exit;

//Sync id
sync_id = noone;
sync_id_assign();

//Variables
player_variables_init_start();

//Character init
switch(global.p1_select)
{
	case 1:
	blocky_character_init();
	break;
	
	case 2:
	lex_character_init();
	break;
}

//Set any variables that need the character init script to run first
player_variables_init_end();

/* Copyright 2024 Springroll Games / Yosi */