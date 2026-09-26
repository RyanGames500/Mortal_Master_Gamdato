if (global.show_scanlines)
{
// Desactiva la interpolación solo para dibujar las scanlines nítidas
var _interpolation = gpu_get_texfilter();
gpu_set_texfilter(false);

// Dibuja las scanlines (puedes bajar a 0.15 o 0.2 si se ve muy oscuro)
draw_sprite_tiled_ext(spr_scalines, 0, 0, 0, 1, 1, c_white, 0.5);

// Restaura la configuración previa
gpu_set_texfilter(_interpolation);
}