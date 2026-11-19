//Pruebas: la 2da ventana usa otra cuenta de Gamdato
if (prueba_instancia_num() == 2) then global.GMDA_LOG_FILE = "gamdato_2.dat";
prueba_latido();
//Id y Clave de juego de Mortal Master en Gamdato
gmda_setController("ac850458-90dc-4d5f-bc52-bf330ce49617", "gd_1ffb8ac0deef9243885a92a81080690e");
gmda_setLeaderboard("survival");
gmda_getBootstrap();
//gmda_syncAlwaysDownload();
global.p1_select = 1; // Por defecto Joe
global.p2_select = 4; // Por defecto Lex