/*
A single hitbox that can collide with hurtboxes.
Hitboxes will run <hitbox_update> every step unless <custom_update> is set to a different script.
Hitboxes will be invisible unless <show_hitboxes> is true.
You can also set a <custom_draw> script for hitboxes.
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
damage = 10;
lifetime = 5;
hitlag = 7;
hitstun = 20;
knockback = 15;
launch_speed = 0;
high = false;
low = false;
grab = false;
grounded_only = false;
to_be_destroyed = false;
destroy_on_stop = false;
custom_update = -1;
custom_draw = -1;
image_blend = c_red;
knockdown = false;
//esclusivas de mayel
boomerang_state = 0;
brake_timer = 0;
has_hit_forward = false;
has_hit_return = false;
shake = 6;