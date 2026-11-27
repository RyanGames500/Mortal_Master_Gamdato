global.local_vs_human = false;

#macro LOCAL_VS_SINGLE_PAD_P2	true

function local_vs_human()
	{
	return (variable_global_exists("local_vs_human") && global.local_vs_human && !global.online_mode && !global.replay_mode);
	}