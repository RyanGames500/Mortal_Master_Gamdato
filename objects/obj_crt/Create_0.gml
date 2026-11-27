depth = 100000;

application_surface_draw_enable(false);

u_scan = shader_get_uniform(sh_crt, "u_scan");
u_vig  = shader_get_uniform(sh_crt, "u_vig");
u_aber = shader_get_uniform(sh_crt, "u_aber");
u_rows = shader_get_uniform(sh_crt, "u_rows");

o_scan = shader_get_uniform(sh_crt_overlay, "u_scan");
o_vig  = shader_get_uniform(sh_crt_overlay, "u_vig");
o_rows = shader_get_uniform(sh_crt_overlay, "u_rows");