// 1. Cambiamos el método al sistema de temporizado por reloj (Sleep)
display_set_timing_method(tm_sleep);

// 2. Ajustamos el margen de espera a un valor alto (entre 10 y 15)
// Esto le dice a GameMaker que use más CPU para vigilar activamente 
// el reloj del sistema y clavar los 60 FPS sin retrasarse.
display_set_sleep_margin(15);

//Id y Clave de juego de Mortal Master en Gamdato
gmda_setController("ac850458-90dc-4d5f-bc52-bf330ce49617", "gd_1ffb8ac0deef9243885a92a81080690e");
gmda_getBootstrap();
//gmda_syncAlwaysDownload();
global.p1_select = 1; // Por defecto Joe
global.p2_select = 4; // Por defecto Lex