//Free the lobby, so other players can use the code you reserved
//The code is also automatically freed after a certain number of minutes
var _b = buffer_create(1, buffer_grow, 1);
server_send_packet(obj_ggmr_net.net_socket, _b, "private_lobby_free");
buffer_delete(_b);

/* Copyright 2024 Springroll Games / Yosi */