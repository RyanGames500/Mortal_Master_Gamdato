

//Nivel actual de barra (0 a 3). Se llama desde el jugador.
function meter_level()
	{
	return floor(meter / METER_LEVEL_SIZE);
	}

function meter_can_pay(_cost)
	{
	return (meter >= _cost);
	}

function meter_pay(_cost)
	{
	meter = max(meter - _cost, 0);
	}

//True si los dos botones se pulsaron casi a la vez (versión EX)
function input_ex_pair(_a, _b)
	{
	return (inputs[@ _a] <= EX_BUTTON_WINDOW && inputs[@ _b] <= EX_BUTTON_WINDOW);
	}

//Consume los botones para que el EX no se dispare dos veces
function input_ex_consume()
	{
	inputs[@ INPUT.attack_light]  = input_store_max;
	inputs[@ INPUT.attack_light2] = input_store_max;
	inputs[@ INPUT.attack_heavy]  = input_store_max;
	}
	

//Temblor, pausa corta y brillo de color al activar un EX (nuestro)
function ex_activation_fx()
	{
	obj_game.cam_shake = max(obj_game.cam_shake, 5);
	
	ex_flash = 45;
	
	hitlag_frame = EX_FREEZE_FRAMES;
	with (obj_player)
		{
		if (id != other.id)
			{
			hitlag_frame = max(hitlag_frame, EX_FREEZE_FRAMES);
			}
		}
	}
	
//True si el ataque actual es un normal que puede cancelarse en especial (nuestro)
function attack_cancelable_normal()
	{
	return (attack_script == attacks[$ "light_ground"]
		 || attack_script == attacks[$ "medium_ground"]
		 || attack_script == attacks[$ "light_crouch"]
		 || attack_script == attacks[$ "medium_crouch"]);
	}

//True si mi ataque conecto Y el rival esta en hitstun (no bloqueado) (nuestro)
function attack_hit_confirmed()
	{
	if (!attack_connected) then return false;
	
	var _hit = false;
	with (obj_player)
		{
		if (id != other.id
			&& (state == PLAYER_STATE.hitstun_ground || state == PLAYER_STATE.hitstun_aerial))
			{
			_hit = true;
			}
		}
	return _hit;
	}
	
//True si el personaje puede lanzar un especial ahora (incluye el cancel de normales) (nuestro)
function special_state_ok()
	{
	return (state == PLAYER_STATE.idle ||
			state == PLAYER_STATE.crouch ||
			state == PLAYER_STATE.walk_forward ||
			state == PLAYER_STATE.dash ||
			(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y) ||
			(state == PLAYER_STATE.attacking && attack_cancelable_normal() && attack_hit_confirmed() && bbox_bottom >= obj_ground.y));
	}	
	
function hp_heal(_amount)
	{
	var _old = hp;
	hp = min(hp + _amount, hp_top);
	if (hp_prev < hp) then hp_prev = hp;	// que la barra no muestre la curacion como dano
	return hp - _old;
	}
	
function special_button_ok(_btn, _pair_btn)
	{
	if (meter_can_pay(METER_COST_EX))
		{
		// con barra para EX: espera la ventana por si llega el segundo boton
		return (inputs[@ _btn] == EX_BUTTON_WINDOW && inputs[@ _pair_btn] > EX_BUTTON_WINDOW);
		}
	return input_pressed(_btn);
	}	