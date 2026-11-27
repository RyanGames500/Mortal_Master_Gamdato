///@category GGMR
///@param {string} name					The name of the player using the chat
///@param {array} [preset_messages]		An array of preset message strings. Pass undefined to not change the preset messages
///@param {asset} [preset_script]		A script to run when a dynamic preset message (a message starting with "%") is selected to send
///@param {int} [max_messages]			The maximum number of messages stored in history
///@param {bool} [clear]				Whether to clear existing messages or not
///@param {bool} [allow_custom]			Whether to let players send anything they want, or to restrict them to the presets
///@param {int} [timeout]				The number of frames a player must wait before sending another message
function ggmr_chat_init()
	{
	if (!instance_exists(obj_ggmr_chat))
		{
		instance_create_layer(0, 0, layer, obj_ggmr_chat);
		}
	with (obj_ggmr_chat)
		{
		chat_name = argument[0];
		if (argument_count > 1 && !is_undefined(argument[1])) then chat_preset_messages = argument[1];
		if (argument_count > 2) then chat_preset_script = argument[2];
		if (argument_count > 3) then chat_max_messages = argument[3];
		if (argument_count > 4 && argument[4]) then chat_history = [];
		if (argument_count > 5) then chat_allow_custom = argument[5];
		if (argument_count > 6) then chat_timeout_max = argument[6];
		return id;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */