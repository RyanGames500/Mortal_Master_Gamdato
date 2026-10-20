/*
Initializes variables for a player BEFORE the character init script is run.
*/
function player_variables_init_start()
	{
	//Player variables
	player_number = 0;

	anim_sprite = spr_blocky_idle;
	anim_frame = 0;
	anim_speed = anim_speed_default;
	facing = 1;
	
	state = PLAYER_STATE.idle;
	state_changed = false;
	state_frame = 0;
	state_time = 0;
	
	hitlag_frame = 0;
	block_pushback = 0;

	hsp = 0;
	vsp = 0;
	
	hp = 0;
	hp_prev = 0;
	//barra de especiales, super y EX
	meter = 0;
	meter_max = 300;
	
	attack_script = -1;
	attack_frame = 0;
	attack_phase = 0;
	attack_connected = false;
	
	hurtbox = noone;
	
	inputs = array_create(INPUT.LENGTH, input_store_max);
	motion_input_direction = array_create(motion_input_array_size, STICK_DIR.neutral);
	motion_input_frame = array_create(motion_input_array_size, 0);
	
	//Character-specific variables that may be overridden in the character init script
	walk_speed = 0;
	dash_speed = 0;
	dash_time = 0;
	jump_hsp = 0;
	jump_vsp = 0;
	grav = 0;
	
	hp_max = 0;
	
	sprite_scale = 0;
	
	sprite_index = -1;
	
	palette_sprite = -1;
	
	hurtbox_sprite = spr_blocky_hurtbox;
	
	sprites = {};
	attacks = {};
	
	passive = -1;
	
	sound_hit_light_index = 0;
	sound_hit_heavy_index = 0;
	being_carried = false;
	jump_impulse_done = false;
	air_hits = 0;
	air_hit_limit = 3;
	combo_hits = 0;
	combo_active = false;
	combo_show = 0;
	combo_final_hits = 0;
	combo_final_show = 0;
	combo_ended_n = 0;
	frozen = false;
	rage_frames = 0;
	acid_ko = false;	// true = este jugador murió por un golpe marcado y debe caer al ácido
	acid_ko = false;
    acid_x = 0;
    acid_y = 0;
    acid_dir = 1;
	ex_flash = 0;		//frames restantes del brillo de EX (nuestro)
	ex_glow_color = make_colour_rgb(255, 40, 40);	//color del brillo, se puede cambiar por personaje (nuestro)
	hp_top = 0;
		// Personajes del escenario (nuestro)
	npc_seq = -1;		// -1 = libre; 0 o más = frames de la secuencia de agarre
	npc_idx = 0;		// qué equipo lo agarró
	npc_linger = 0;		// frames seguidos dentro de la zona de un equipo
	npc_back = -1;
	npc_back_idx = 0;
	super_id = 0;		//que super se esta lanzando, para mostrar su nombre (nuestro)
	super_fx = 0;		//frames restantes del efecto de super (nuestro)
	super_hit_fx = 0;	//frames restantes del destello de impacto (nuestro)
	super_invuln = false;	//true = el jugador es intocable (supers) (nuestro)
	super_zoom = 1.0;
	super_green = 0;	
	super_lock = false;	
	//diferenciar espejos de cada peleador duplicado
	current_pal = 0
	override_surface=noone;
	override_pal_index=0;
	step_shake = 0;		//temblor de camara al pisar (0 = ninguno) (nuestro)
	land_shake = 0;		//temblor de camara al aterrizar (0 = ninguno) (nuestro)
	pal_swap_init_system(shd_pal_swapper,shd_pal_html_sprite,shd_pal_html_surface);
	}


/* Copyright 2024 Springroll Games / Yosi */