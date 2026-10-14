/*
This object draws the background during matches.
*/


// Capa delantera del stage: se dibuja por encima de los personajes
if (!instance_exists(obj_stage_front)) then instance_create_depth(0, 0, -5000, obj_stage_front);