// Conseguir la Y actual de la cámara para poder desfasar el fondo hacia arriba
var _cam_y = camera_get_view_y(view_camera[0]);

// Dibujar el fondo restándole los 300 píxeles que quieres que suba
draw_sprite_ext(spr_background, 0, 0, _cam_y - 500, 6, 6, 0, c_white, 1.0);

/* Copyright 2024 Springroll Games / Yosi */