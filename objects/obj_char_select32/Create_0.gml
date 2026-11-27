/// @description Inicialización CSS
global.replay_mode = false;
characters = [
	{ name: "JOE",     char_id: 1, color: c_orange },
    { name: "LEX",     char_id: 2, color: c_red },
    { name: "BLITSEN", char_id: 3, color: c_yellow },
    { name: "SAORI",   char_id: 4, color: c_fuchsia },
    { name: "SCAR",    char_id: 5, color: c_lime }
];

char_count = array_length(characters);

p1_cursor = 0;
p2_cursor = 1;

p1_confirmed = false;
p2_confirmed = false;

start_timer = -1;

