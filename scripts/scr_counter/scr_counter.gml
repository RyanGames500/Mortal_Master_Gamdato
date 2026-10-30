/*
Counter hit y punish counter (nuestro).
Cada frame se anota en que fase de su ataque esta cada jugador (ch_phase):
0 = startup (todavia no salio su golpe), 1 = golpe activo, 2 = recuperacion.
Todo es determinista y esta en variables del jugador, que el rollback guarda solo.
*/

/* Se llama una vez por frame desde player_update (con el jugador como self) */
function counter_phase_update()
	{
	if (ch_show > 0) then ch_show--;
	
	if (state != PLAYER_STATE.attacking)
		{
		ch_phase = 0;
		ch_script = -1;
		return;
		}
	
	// ataque nuevo: vuelve a empezar desde el startup
	if (ch_script != attack_script)
		{
		ch_script = attack_script;
		ch_phase = 0;
		}
	
	// que hitboxes suyas existen ahora: golpe normal o proyectil
	var _melee = false;
	var _proj = false;
	with (obj_hitbox)
		{
		if (owner != other.id || to_be_destroyed) then continue;
		if (destroy_on_stop)
			{
			if (damage > 0) then _proj = true;
			}
		else if (damage > 0 || grab)
			{
			_melee = true;
			}
		}
	
	if (_melee) then ch_phase = 1;
	else if (ch_phase == 1) then ch_phase = 2;
	if (_proj && ch_phase < 2) then ch_phase = 2;		// lanzar un proyectil cuenta como que ya "saco" su golpe
	}

/* Se llama con el golpeado como self, ANTES de attack_stop(). Devuelve 0 normal, 1 counter, 2 punish counter. */
function counter_hit_kind()
	{
	if (state != PLAYER_STATE.attacking) then return 0;
	if (super_id != 0 || super_invuln) then return 0;		// un super no se contragolpea
	return (ch_phase == 2) ? 2 : 1;
	}
	
/* Dano final de un golpe de proyectil (nuestro): reduccion por combo y bonus de counter.
   Se llama con el golpeado como self. _attacker = quien lanzo el proyectil. */
function projectile_hit_damage(_dmg, _ch, _attacker)
	{
	var _nth = combo_active ? (combo_hits + 1) : 1;		// numero de este golpe dentro del combo
	var _scale = 1;
	if (_attacker.super_id == 0) then _scale = combo_damage_scale(_nth);
	if (_ch == 1) then _scale *= 1.2;		// counter: +20% de dano
	if (_ch == 2) then _scale *= 1.5;		// punish counter: +50% de dano
	return _dmg * _scale;
	}

/* Marca el counter en el golpeado (para el letrero) y devuelve los frames extra de hitstun (nuestro).
   Se llama con el golpeado como self. */
function counter_hit_finish(_ch)
	{
	if (_ch > 0)
		{
		ch_kind = _ch;
		ch_show = 60;
		}
	return (_ch == 1) ? 4 : ((_ch == 2) ? 8 : 0);
	}	