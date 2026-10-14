// El juego se dibuja primero (al fondo del Draw GUI), y todo el HUD y los menús quedan encima
depth = 100000;

//if (!variable_global_exists("show_scanlines")) then global.show_scanlines = true;

// Nosotros dibujamos la application_surface a mano para pasarla por el shader
application_surface_draw_enable(false);

// Pasada 1: el juego (aberración cromática)
u_scan = shader_get_uniform(sh_crt, "u_scan");
u_vig  = shader_get_uniform(sh_crt, "u_vig");
u_aber = shader_get_uniform(sh_crt, "u_aber");
u_rows = shader_get_uniform(sh_crt, "u_rows");

// Pasada 2: capa final sobre todo (scanlines y viñeta)
o_scan = shader_get_uniform(sh_crt_overlay, "u_scan");
o_vig  = shader_get_uniform(sh_crt_overlay, "u_vig");
o_rows = shader_get_uniform(sh_crt_overlay, "u_rows");