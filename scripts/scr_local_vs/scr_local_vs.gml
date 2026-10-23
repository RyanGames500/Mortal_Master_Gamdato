/* VS local de 2 humanos (nuestro) */
global.local_vs_human = false;		// true = LOCAL VS con dos humanos · false = el rival es la CPU (arcade)

// Si en VS local hay UN solo mando conectado: true = es del P2 (P1 usa teclado) · false = es del P1 (P2 usa teclado)
#macro LOCAL_VS_SINGLE_PAD_P2	true

// True solo en LOCAL VS de dos humanos (nunca online, ni en replay)
function local_vs_human()
	{
	return (variable_global_exists("local_vs_human") && global.local_vs_human && !global.online_mode && !global.replay_mode);
	}