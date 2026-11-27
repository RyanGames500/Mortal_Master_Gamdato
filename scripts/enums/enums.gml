enum GAME_META_STATE
	{
	starting,
	running,
	ending,
	round_restart,
	char_select
	}

enum PLAYER_STATE
	{
	idle,
	walk_forward,
	walk_backward,
	aerial,
	crouch,
	dash,
	dash_left,
	blockstun,
	hitstun_ground,
	hitstun_aerial,
	grabbed,
	attacking,
	knockdown,
	acostado,
	getup,
	
	LENGTH,
	}

enum INPUT
	{
	stick_dir,
	attack_light,
	attack_heavy,
	pause,
	attack_light2,
	
	LENGTH,
	}

enum STICK_DIR
	{
	forward_down,
	forward,
	forward_up,
	forward_any,
	up,
	up_any,
	backward_up,
	backward,
	backward_down,
	backward_any,
	down,
	down_any,
	neutral,
	}

enum ATTACK_PHASE
	{
	start = -1,
	stop = -2,
	}

enum MENU_STATE
	{
	main,
	online,
	private_lobby,
	replays,
	settings,
	input_text,
	survival,
	ranking
	}