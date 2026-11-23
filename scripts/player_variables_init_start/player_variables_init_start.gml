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
	//Pose de victoria (nuestro)
	win_pose = false;		//ya está haciendo la pose
	win_wait = 0;			//espera antes de empezarla 
	combo_hits = 0;
	combo_active = false;
	combo_show = 0;
	combo_final_hits = 0;
	combo_final_show = 0;
	combo_ended_n = 0;
	frozen = false;
	frz_age = 0;		// frames que lleva congelado
	frz_break = -1;		// frames desde que se rompió el hielo (-1 = nada)
	frz_bx = 0;			// donde estaba cuando se rompió
	frz_by = 0;
	frz_bface = 1;
	frz_dx = 0;			// donde le pegó la bola (respecto a él)
	frz_dy = 0;	
	rage_frames = 0;
	acid_ko = false;	// true = este jugador murió por un golpe marcado y debe caer al ácido
	acid_ko = false;
    acid_x = 0;
    acid_y = 0;
    acid_dir = 1;
	//Fatality
	fatal_type = FATALITY.none;	// qué fatality le hicieron a este jugador
	fatal_x = 0;
	fatal_dir = 1;
	fatal_launch = 24;
	fatal_timer = 0;			// contador del fatality en entrenamiento	
	fatal_y = 0;
	fatal_spr = -1;		// sprite del rival al recibir el golpe (congelado)
	fatal_img = 0;
	fatal_face = 1;
	fatal_trophy = false;		// true = levantando el trofeo del fatality columna
	fatal_hold = 0;				// frames que se queda congelado en el golpe del trofeo
	fatal_hold_spr = -1;
	fatal_hold_img = 0;
	fatal_tongue = false;
	fatal_bx = 0;
	fatal_tx = 0;
	fat_lengua = -1;	
	fat_hand_hit = undefined;	// dónde está la mano en el golpe del fatality columna
	fat_hand_win = undefined;	// dónde está la mano en cada frame de la pose de victoria	
	no_fatality = false;		// true en los jefes: sin fatality ni stage fatality
	fat_cabeza = -1;			// arte de este char como víctima (cada char pone el suyo en su init)
	fat_cuerpo = -1;
	fat_pies = -1;	
	ex_flash = 0;		//frames restantes del brillo de EX (nuestro)
	ex_glow_color = make_colour_rgb(255, 40, 40);	//color del brillo, se puede cambiar por personaje (nuestro)
	hp_top = 0;
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
	super_freeze_hits = -1;
	ch_phase = 0;		// fase de mi ataque: 0 startup, 1 activo, 2 recuperacion (nuestro)
	ch_script = -1;		// ataque que estoy midiendo (nuestro)
	ch_kind = 0;		// 1 counter, 2 punish counter: el ultimo que recibi (nuestro)
	ch_show = 0;		// frames que se muestra el letrero (nuestro)
	draw_extra = -1;	// efectos propios del personaje (nuestro)	
	//diferenciar espejos de cada peleador duplicado
	current_pal = 0
	override_surface=noone;
	override_pal_index=0;
	step_shake = 0;		//temblor de camara al pisar (0 = ninguno) (nuestro)
	land_shake = 0;		//temblor de camara al aterrizar (0 = ninguno) (nuestro)
	pal_swap_init_system(shd_pal_swapper,shd_pal_html_sprite,shd_pal_html_surface);
	}


/* Copyright 2024 Springroll Games / Yosi */