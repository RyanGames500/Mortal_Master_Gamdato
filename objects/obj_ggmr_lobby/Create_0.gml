///@category GGMR

lobby_state = GGMR_LOBBY_STATE.idle;

lobby_timer = 0;

lobby_members = ds_list_create();

is_lobby_leader = true;

lobby_member_number = 0;
lobby_member_name = "";


lobby_custom_data = {};

lobby_reset_callback = undefined;

ggmr_net_init();

lobby_joined_connection = -1;
lobby_joined_name = "";

lobby_join_requests = ds_list_create();

lobby_buffer = buffer_create(1, buffer_grow, 1);

lobby_session_is_started = false;

/* Copyright 2024 Springroll Games / Yosi */