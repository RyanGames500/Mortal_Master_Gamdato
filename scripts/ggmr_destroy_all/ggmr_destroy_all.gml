///@category GGMR
function ggmr_destroy_all()
	{
	instance_destroy(obj_ggmr_chat);
	instance_destroy(obj_ggmr_custom);
	instance_destroy(obj_ggmr_lobby);
	instance_destroy(obj_ggmr_logger);
	instance_destroy(obj_ggmr_net);
	instance_destroy(obj_ggmr_session);
	ggmr_log("Destroyed all GGMR objects!");
	}

/* Copyright 2024 Springroll Games / Yosi */