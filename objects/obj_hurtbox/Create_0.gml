/*
A hurtbox that is attached to a player.
It is invisible unless <show_hitboxes> is true.
*/

//Game state loading
if (obj_game.game_state_is_loading) then exit;

//Sync id
sync_id = noone;
sync_id_assign();

//Variables
owner = noone;
x_offset = 0;
y_offset = 0;
lifetime = -1;

image_speed = 0;
image_blend = c_lime;

/* Copyright 2024 Springroll Games / Yosi */