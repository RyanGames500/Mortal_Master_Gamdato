/// @description Inicialización del Menú Centralizado
randomize();

// --- LÓGICA DE RED Y LOBBY DE YOSI ENGINE ---
lobby_code = "Not Set Yet";
ggmr_net_init();
ggmr_lobby_init(global.online_name, function() { main_menu_ui_refresh(); });

if (global.online_lobby_members != "")
	{
	ggmr_lobby_members_load(global.online_lobby_members);
	}

previous_number_of_players = 1;

// Noticias del Servidor
if (global.news == "Could not contact the matchmaking server!")
	{
	var _b = buffer_create(1, buffer_grow, 1);
	server_send_packet(obj_ggmr_net.net_socket, _b, "fetch_news", version_string);
	buffer_delete(_b);
	}


current_state = MENU_STATE.main;
menu_index = 0;
prev_menu_index = 0;

// Animaciones y Efectos
menu_scale = []; // Para el efecto de "zoom" al seleccionar
text_alpha = 0;

// Listas de Opciones por Pantalla
menu_options = [
	"LOCAL VS",
	"ARCADE",
	"SURVIVAL",
	"ONLINE MATCHMAKING",
	"REPLAYS",
	"SETTINGS",
	"EXIT"
];

online_options = [
	"QUICK PLAY",
	"SALA PRIVADA",
	"BACK"
];

// Se rearma cada frame en el Step con private_lobby_menu_build()
private_lobby_options = ["SET LOBBY CODE", "JOIN LOBBY BY CODE", "BACK"];
private_lobby_actions = ["set_code", "join_code", "back"];
private_lobby_args = [0, 0, 0];
// true = el anfitrión acepta solo a quien entra con su código (sin botón ACCEPT)
private_lobby_auto_accept = false;
settings_options = ["MUSIC VOLUME", "SFX VOLUME", "MENU VOLUME", "ENABLE SCANLINES", "RECORD REPLAYS", "SET NAME", "SET INPUT DELAY", "BACK"];



// Variables para Teclado Virtual / Input en Pantalla (Reemplazo de get_string)
input_target = ""; // "ip", "port", "code", "delay", "name"
input_string = "";
input_prompt = "";

// Variables para el mensaje emergente
notice_text = "";
notice_timer = 0;

// 2. Variables para la lista de archivos
replay_list = [];
replay_index = 0;

// Animación del menu
sel_y_smooth = 0;
sel_y_ready = false;
menu_state_prev_draw = current_state;
menu_transition = 1; // 0 = recien cambiado de pantalla, 1 = totalmente asentado

hit_rects = [];			// rectangulos tocables (los llena el Draw cada frame)
ptr_last_x = -1;
ptr_last_y = -1;
text_kb_opened = false;
delete_armed = -1;

scan_replay_files();
audio_group_load(audiogroup_music);