// Pasada 1: dibuja el juego en pantalla, con aberración cromática si el efecto está activo.
var _w = display_get_gui_width();
var _h = display_get_gui_height();

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

if (global.show_scanlines)
	{
	shader_set(sh_crt);
	shader_set_uniform_f(u_scan, 0);	// las scanlines y la viñeta van en la pasada final
	shader_set_uniform_f(u_vig, 0);
	shader_set_uniform_f(u_aber, 0.012);
	shader_set_uniform_f(u_rows, camera_height);
	draw_surface_stretched(application_surface, 0, 0, _w, _h);
	shader_reset();
	}
else
	{
	draw_surface_stretched(application_surface, 0, 0, _w, _h);
	}