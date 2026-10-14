/*
This object displays a certain visual effect.
*/

//Game state loading
if (obj_game.game_state_is_loading) then exit;

//Sync id
sync_id = noone;
sync_id_assign();

//Variables
lifetime = 10;
anim_speed = 1;
owner = noone;

image_speed = 0;

/* Copyright 2024 Springroll Games / Yosi */