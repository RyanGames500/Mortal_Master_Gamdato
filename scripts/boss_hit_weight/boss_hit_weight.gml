///@param {id} hitbox			El hitbox al que se le da peso
///@param {int} tier			Nivel de peso: 1 = golpe rápido, 2 = medio, 3 = golpe pesado
///@param {bool} [keep_advantage]	Si es true (por defecto) se compensa el hitstun para no cambiar la ventaja del golpe
function boss_hit_weight(_hitbox, _tier, _keep_advantage = true)
	{
	static _hitlag = [12, 14, 17];
	static _shake = [7, 9, 12];
	static _min_knockback = [15, 20, 25];
	
	var _t = clamp(_tier, 1, 3) - 1;
	
	if (_keep_advantage)
		{
		_hitbox.hitstun = max(1, _hitbox.hitstun - (_hitlag[_t] - _hitbox.hitlag));
		}
	_hitbox.hitlag = _hitlag[_t];
	_hitbox.shake = _shake[_t];
	_hitbox.knockback = max(_hitbox.knockback, _min_knockback[_t]);
	}