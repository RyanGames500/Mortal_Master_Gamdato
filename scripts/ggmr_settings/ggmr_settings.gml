///@category GGMR
/* 
Inicializa todas las constantes utilizadas por GGMR.
Este script se ejecuta automáticamente al inicio del juego.
*/
#macro GGMR_DEBUG_LOG							false //{bool} Si el juego debe dibujar los mensajes de depuración en pantalla e imprimirlos en la consola o no.
#macro GGMR_DEBUG_LOG_SIZE						10 //{int} El número de mensajes registrados que se mantendrán guardados.
#macro GGMR_NET_DEBUG_OVERLAY					false //{bool} Si el juego debe dibujar la superposición de depuración de RED (NET) o no.
#macro GGMR_SESSION_DEBUG_OVERLAY				false //{bool} Si el juego debe dibujar la superposición de depuración de la sesión o no.
#macro GGMR_CUSTOM_DEBUG_OVERLAY				false //{bool} Si el juego debe dibujar la superposición de depuración personalizada o no.

#macro GGMR_ONLINE_INDICATOR					false //{bool} Si el juego debe dibujar el indicador en línea en la esquina inferior derecha o no.
#macro GGMR_CONNECTION_COUNTER					false //{bool} Si el juego debe dibujar el contador de conexiones en la esquina inferior derecha o no.

#macro GGMR_PLAYERS_MIN							2 //{int} Número mínimo de jugadores (locales o remotos) necesarios para iniciar una partida.
#macro GGMR_PLAYERS_MAX							2 //{int} Número máximo de jugadores que pueden ser locales o remotos.
#macro GGMR_SPECTATORS_MAX						6 //{int} Número máximo de jugadores que pueden conectarse como espectadores.
#macro GGMR_MEMBERS_MAX							8 //{int} El número máximo de miembros que pueden estar en un lobby.
#macro GGMR_CLIENTS_MAX							GGMR_MEMBERS_MAX //{int} El número máximo de clientes que pueden estar en una sesión.

#macro GGMR_PREDICTION_FRAMES_MAX				10 //{int} Cuántos frames puede avanzar el juego sin recibir entrada (input) antes de pausarse/congelarse.
#macro GGMR_INPUT_DELAY_MIN						-5 //{int} El número mínimo de frames de retraso de entrada (input delay) que el juego puede establecer.
#macro GGMR_INPUT_DELAY_DEFAULT					2 //{int} El retraso de entrada predeterminado que usará el juego.
#macro GGMR_INPUT_DELAY_MAX						10 //{int} El número máximo de frames de retraso de entrada que el juego puede establecer.

#macro GGMR_LOBBY_TIMEOUT						360 //{int} Cuántos frames esperarán los lobbies antes de desconectar si los miembros no están enviando paquetes.
#macro GGMR_LOBBY_JOIN_TIMEOUT					300 //{int} Cuántos frames duran las solicitudes de unirse antes de expirar.

#macro GGMR_PORT								63568 //{int} El puerto que usa GGMR para todas las conexiones.

#macro GGMR_NET_PING_ARRAY_SIZE					10 //{int} Cuántos valores de ping se almacenan a la vez para calcular el ping promedio.
#macro GGMR_NET_PING_INTERVAL					100 //{int} El número de frames entre cada envío de ping.

#macro GGMR_RIFT_SLOW_THRESHOLD					2.5 //{real} Cuántos frames adelantado puede estar el juego antes de desacelerar.
#macro GGMR_RIFT_SLOW_INTERVAL					7 //{int} Cuántos frames deben pasar antes de que el juego pueda omitir/descartar un frame.
#macro GGMR_RIFT_ACCEL_THRESHOLD				-1.5 //{real} Cuántos frames atrasado puede estar el juego antes de acelerar.
#macro GGMR_RIFT_ACCEL_INTERVAL					4 //{int} Cuántos frames deben pasar antes de que el juego pueda ejecutar múltiples frames a la vez.
#macro GGMR_RIFT_ARRAY_SIZE						10 //{int} Cuántos valores de desfasaje (rift) se almacenan a la vez para calcular el desfasaje promedio.

#macro GGMR_SESSION_START_TIMER					15 //{int} El número predeterminado de frames que espera la sesión antes de iniciar. El número real variará según el ping calculado con el líder.
#macro GGMR_SESSION_DEBUG_FILENAME				"GGMR_DEBUG_STATS.txt" //{string} El nombre del archivo donde se escribirán las estadísticas de depuración.
#macro GGMR_SESSION_DESYNC_TEST_INTERVAL		30 //{int} El número de frames entre cada comprobación de desincronización (desync). Si se detecta un desync, la sesión termina inmediatamente.
#macro GGMR_SESSION_FRAME_SKIP_ENABLED			true //{bool} Si el juego puede avanzar frames sin renderizarlos cuando el juego corre a menos de 60fps o no.
#macro GGMR_SESSION_DISCONNECT_TIME				5000 //{int} El número de milisegundos que el juego puede pasar sin recibir paquetes antes de desconectarse. Las desconexiones se comprueban cada 60 frames.

#macro GGMR_SPECTATOR_FRAMES					3 //{int} El número de frames a enviar a los espectadores en cada paso (step). Enviar más frames evita que los espectadores se congelen si pierden algunos paquetes.
#macro GGMR_SPECTATOR_ACCEL_THRESHOLD			3 //{int} El número de frames atrasado que puede estar un espectador antes de acelerar.

#macro GGMR_SESSION_GC_DURING_FRAME_DROPS		true //{bool} Si el juego debe ejecutar el recolector de basura (garbage collector) cuando espera a que el juego del oponente se ponga al día o no.
#macro GGMR_SESSION_GC_DURING_ROLLBACKS			false //{bool} Si el juego debe ejecutar el recolector de basura cuando ocurre un rollback o no.
#macro GGMR_SESSION_GC_DURING_NONROLLBACKS		false //{bool} Si el juego debe ejecutar el recolector de basura en frames que no sean de rollback o no.
#macro GGMR_SESSION_GC_AUTO_DISABLE				false //{bool} Si el juego debe desactivar la recolección automática de basura o no.

#macro GGMR_CHAT_BLOCK_UNKNOWN_SENDERS			true //{bool} Si el chat debe ignorar los mensajes de combinaciones de IP y puerto que no estén en la lista de conexiones de red.

//Valores del Jugador / Cliente
enum GGMR_CLIENT 
	{
	connection,
	name,
	client_type,
	last_confirmed,
	location,
	last_packet_number,
	last_frame,
	frame_advantage,
	input_delay,
	finished,
	}

//Tipos de Conexión
enum GGMR_LOCATION_TYPE 
	{
	local,
	remote,
	}

//Tipos de Jugador
enum GGMR_CLIENT_TYPE 
	{
	player,
	spectator,
	}

//Tipos de Predicción
enum GGMR_PREDICTION_TYPE 
	{
	copy,
	template,
	}

//Eventos de GGMR
enum GGMR_EVENT 
	{
	prediction_limit_reached,
	desync_check,
	desync_detected,
	disconnect,
	input_check_blank,
	}

//Valores del Frame
enum GGMR_FRAME 
	{
	number,
	inputs,
	received,
	confirmed,
	game_state,
	rolled_back,
	recorded,
	times_ran,
	}

//Estados del Lobby
enum GGMR_LOBBY_STATE 
	{
	idle,
	joining,
	}

//Estados de la Sesión
enum GGMR_SESSION_STATE 
	{
	start,
	normal,
	ending,
	disconnected,
	}

//Red / Paquetes
enum GGMR_PACKET_TYPE 
	{
	//Lobby
	join,
	join_confirmation,
	join_denial,
	leave,
	heartbeat,
	ready,
	start_time,
	sync,
	kick,
	
	//RED (NET)
	ping,
	pong,
	
	//Sesión
	input,
	finished,
	desync_data,
	desync_detected,
	input_delay_request,
	input_delay,
	
	//Personalizado
	custom_heartbeat,
	custom_data,
	
	//Chat
	chat_message,
	
	//No es parte de GGMR
	ignore = 123, //123 es el código para el carácter "{", que indica el inicio de una cadena JSON.
	}

//Valores de los Miembros del Lobby
enum GGMR_LOBBY_MEMBER 
	{
	connection,
	client_type,
	name,
	ready,
	silence,
	location,
	}
	
//Códigos de Estado del Lobby
enum GGMR_LOBBY_STATUS
	{
	ok,
	too_few_players,
	too_many_players,
	too_many_spectators,
	too_many_members,
	}
	
//Valores de Solicitud para Unirse al Lobby
enum GGMR_LOBBY_JOIN_REQUEST 
	{
	ip,
	port,
	name,
	silence,
	}

//Globales
function ggmr_globals()
	{
	static properties = 
		{
		//Sesión
		session_start_time :			0, //{real} El número de milisegundos que esperará la sesión antes de iniciar, en un intento de arrancar a todos los jugadores al mismo tiempo.
		};
	return properties;
	}

#region Constantes
#macro GGMR_RELATIVE_FRAME				(GGMR_PREDICTION_FRAMES_MAX + 1) //{int} El índice en la matriz de frames que corresponde al frame actual.
#macro GGMR_MAX_FRAMES_STORED			(GGMR_PREDICTION_FRAMES_MAX + 1 + GGMR_INPUT_DELAY_MAX + 1) //{int} La longitud total de la matriz de frames almacenados.
#macro GGMR_BLANK_PORT					0 //{int} El puerto "en blanco" o nulo.
#macro GGMR_BLANK_IP					"0.0.0.0" //{string} La dirección IP "en blanco" o nula.
#endregion

/* Copyright 2024 Springroll Games / Yosi */