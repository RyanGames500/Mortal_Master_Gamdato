/*
The overall phase the game is in.
*/
enum GAME_META_STATE
	{
	starting,
	running,
	ending,
	round_restart
	}

/*
All possible states players can be in.
*/
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
	
	LENGTH,
	}

/*
All the different inputs that the game logic can use.
*/
enum INPUT
	{
	stick_dir,
	attack_light,
	attack_heavy,
	pause,
	attack_light2,
	
	LENGTH,
	}

/*
The different directions you can check the control stick for.
The "any" directions cover a full 90 degrees, while the other directions cover 30 degrees each.
*/
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

/*
Reserved numbers for attack phases.
Any other numbers are free to be used for any types of phases in attack scripts.
*/
enum ATTACK_PHASE
	{
	start = -1,
	stop = -2,
	}

/* Copyright 2024 Springroll Games / Yosi */