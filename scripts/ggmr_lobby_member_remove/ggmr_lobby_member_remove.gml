///@category GGMR
///@param {int} index		The lobby member to remove
function ggmr_lobby_member_remove()
	{
	with (obj_ggmr_lobby) 
		{
		ds_list_delete(lobby_members, argument[0]);
		return true;
		}
	ggmr_crash("obj_ggmr_lobby did not exist when ggmr_lobby_member_remove was called");
	}

/* Copyright 2024 Springroll Games / Yosi */