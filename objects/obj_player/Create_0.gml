// Game state loading
if (obj_game.game_state_is_loading) then exit;

// Sync id
sync_id = noone;
sync_id_assign();

// Solo limpiar variables base, NO cargar ningun personaje todavía
player_variables_init_start();