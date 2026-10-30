//Draw action lines based on how much lifetime the instance has left
draw_action_lines(x, y, camera_get_view_width(camera_index), camera_get_view_height(camera_index), 15, 50, lerp(400, 100, lifetime / 20));

/* Copyright 2024 Springroll Games / Yosi */