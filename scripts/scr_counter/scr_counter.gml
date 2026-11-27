
function counter_phase_update()
	{
	if (ch_show > 0) then ch_show--;
	
	if (state != PLAYER_STATE.attacking)
		{
		ch_phase = 0;
		ch_script = -1;
		return;
		}
	
	if (ch_script != attack_script)
		{
		ch_script = attack_script;
		ch_phase = 0;
		}
	
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
	if (_proj && ch_phase < 2) then ch_phase = 2;
	}

function counter_hit_kind()
	{
	if (state != PLAYER_STATE.attacking) then return 0;
	if (super_id != 0 || super_invuln) then return 0;
	return (ch_phase == 2) ? 2 : 1;
	}
	
function projectile_hit_damage(_dmg, _ch, _attacker)
	{
	var _nth = combo_active ? (combo_hits + 1) : 1;
	var _scale = 1;
	if (_attacker.super_id == 0) then _scale = combo_damage_scale(_nth);
	if (_ch == 1) then _scale *= 1.2;
	if (_ch == 2) then _scale *= 1.5;
	return _dmg * _scale;
	}

function counter_hit_finish(_ch)
	{
	if (_ch > 0)
		{
		ch_kind = _ch;
		ch_show = 60;
		}
	return (_ch == 1) ? 4 : ((_ch == 2) ? 8 : 0);
	}	