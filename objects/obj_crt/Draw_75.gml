// Pasada 2: scanlines y viñeta por encima de TODO, HUD y menús incluidos.
if (!global.show_scanlines) then exit;

var _w = display_get_gui_width();
var _h = display_get_gui_height();

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

shader_set(sh_crt_overlay);
shader_set_uniform_f(o_scan, 0.18);
shader_set_uniform_f(o_vig, 0.35);
shader_set_uniform_f(o_rows, camera_height);
// La surface solo sirve para dar coordenadas al shader; su color no se usa
draw_surface_stretched(application_surface, 0, 0, _w, _h);
shader_reset();