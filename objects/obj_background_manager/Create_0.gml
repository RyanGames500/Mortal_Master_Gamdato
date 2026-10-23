/*
This object draws the background during matches.
*/

// Fondo epico de los supers de 3 barras (solo visual)
sbg_a = 0;
sbg_x = 0;
sbg_y = 0;
sbg_col = c_white;

// Capa delantera del stage: se dibuja por encima de los personajes
if (!instance_exists(obj_stage_front)) then instance_create_depth(0, 0, -5000, obj_stage_front);