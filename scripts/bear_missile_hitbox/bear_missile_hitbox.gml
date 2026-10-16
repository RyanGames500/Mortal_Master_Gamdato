/*
Devuelve el jugador rival del dueño del hitbox (nuestro).
No se guarda ninguna referencia a una instancia: se busca cada frame, así el rollback no se rompe.
*/
function bear_missile_target()
	{
	var _target = noone;
	with (obj_player)
		{
		if (id != other.owner)
			{
			_target = id;
			break;
			}
		}
	return _target;
	}

///@param {int} x_offset	Posición en X respecto al oso (se invierte sola según hacia dónde mira)
///@param {int} y_offset	Posición en Y respecto al oso
///@param {real} vx			Velocidad inicial en X (se invierte sola según hacia dónde mira)
///@param {real} vy			Velocidad inicial en Y
///@param {int} age			Edad inicial: mientras sea menor que 12 el misil solo sube sin buscar al rival
/*
Crea un misil teledirigido del oso (nuestro). Se ejecuta dentro del oso.
*/
function bear_missile_spawn(_x_off, _y_off, _vx, _vy, _age)
	{
	var _hitbox = hitbox_create(_x_off, _y_off, 0.5, 0.3, 10, 150);
	_hitbox.destroy_on_stop = true;
	_hitbox.custom_update = bear_missile_hitbox_update;
	_hitbox.custom_draw = bear_missile_hitbox_draw;
	_hitbox.knockback = 12;
	_hitbox.vx = _vx * facing;
	_hitbox.vy = _vy;
	_hitbox.age = _age;
	_hitbox.max_speed = 11;
	_hitbox.turn_rate = 1.0;
	boss_hit_weight(_hitbox, 2);
	return _hitbox;
	}

function bear_missile_hitbox_update()
	{
	//Lifetime
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	//Búsqueda del rival (después de subir un poco)
	age++;
	if (age >= 12)
		{
		var _target = bear_missile_target();
		if (_target != noone)
			{
			var _dx = ((_target.bbox_left + _target.bbox_right) div 2) - x;
			var _dy = ((_target.bbox_top + _target.bbox_bottom) div 2) - y;
			var _dist = max(1, sqrt(_dx * _dx + _dy * _dy));
			
			// Velocidad deseada hacia el rival; la velocidad actual gira hacia ella poco a poco
			vx += clamp((_dx / _dist) * max_speed - vx, -turn_rate, turn_rate);
			vy += clamp((_dy / _dist) * max_speed - vy, -turn_rate, turn_rate);
			}
		}
	
	//Position
	x += vx;
	y += vy;
	
	//Se destruye al salir de la zona de juego
	if (x < -300 || x > room_width + 300 || y < -800 || y > obj_ground.y + 100)
		{
		instance_destroy();
		return;
		}
	
	//Colliding with other projectiles will destroy both projectiles
	var _hitboxes = instance_place_array(x, y, obj_hitbox);
	for (var i = 0; i < array_length(_hitboxes); i++)
		{
		var _hitbox = _hitboxes[@ i];
		
		//You can't hit your own hurtboxes
		if (_hitbox.owner != owner)
			{
			//Check that the hitbox is a projectile
			if (_hitbox.destroy_on_stop)
				{
				to_be_destroyed = true;
				_hitbox.to_be_destroyed = true;
				}
			}
		}
	
	//Colliding with hurtboxes
	var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
	for (var i = 0; i < array_length(_hurtboxes); i++)
		{
		var _hurtbox = _hurtboxes[@ i];
		
		//You can't hit your own hurtboxes
		if (_hurtbox.owner != owner)
			{
			// Si la ronda no está en ejecución o el rival ya no tiene vida, ignorar colisión
			if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
			
			with (_hurtbox.owner)
				{
				//Blocking
				if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
					{
					//Middle / High block
					anim_sprite = sprites[$ "high_block"];
					player_state_set(PLAYER_STATE.blockstun);
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					}
				else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
					{
					//Middle / Low block
					anim_sprite = sprites[$ "low_block"];
					player_state_set(PLAYER_STATE.blockstun);
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					}
				//Hit
				else
					{
					attack_stop();
					
					//Grounded vs aerial hits
					if (bbox_bottom >= obj_ground.y && other.launch_speed == 0)
						{
						player_state_set(PLAYER_STATE.hitstun_ground);
						anim_sprite = sprites[$ "hitstun_ground"];
						anim_speed = anim_speed_default;
						player_face_opponent();
						vsp = 0;
						}
					else
						{
						player_state_set(PLAYER_STATE.hitstun_aerial);
						anim_sprite = sprites[$ "hitstun_aerial"];
						anim_speed = anim_speed_default;
						vsp = -other.launch_speed;
						}
					
					player_damage(other.damage);
					state_frame = other.hitstun;
					hitlag_frame = other.hitlag;
					hsp = other.knockback * other.owner.facing;
					
					//Effects
					obj_game.cam_shake = max(obj_game.cam_shake, other.shake);
					}
				}
			
			// El atacante gana la barra al conectar el proyectil
			with (owner)
				{
				meter = clamp(meter + 6, 0, meter_max);
				}
			
			//Projectiles are destroyed on hit
			to_be_destroyed = true;
			}
		}
	
	//Other destruction checks
	if (to_be_destroyed)
		{
		//VFX (nuestro: la chispa de impacto que ya tienes, hasta tener una explosión propia)
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_effect_spark;
		_vfx.image_xscale = owner.facing;
		_vfx.anim_speed = 0.4;
		_vfx.lifetime = sprite_get_number(_vfx.sprite_index) / _vfx.anim_speed;
		_vfx.owner = owner;
		
		instance_destroy();
		return;
		}
	}

function bear_missile_hitbox_draw()
	{
	// Marcador de objetivo sobre el rival: verde buscando, rojo cuando el misil ya está cerca.
	// Es solo visual: no es una instancia ni se guarda en el rollback.
	var _target = bear_missile_target();
	if (_target != noone)
		{
		var _tx = (_target.bbox_left + _target.bbox_right) div 2;
		var _ty = (_target.bbox_top + _target.bbox_bottom) div 2;
		var _close = (point_distance(x, y, _tx, _ty) < 260) ? 1 : 0;
		draw_sprite_ext(spr_bear_marker, _close, _tx, _ty, owner.sprite_scale, owner.sprite_scale, 0, c_white, 1.0);
		}
	
	// El misil gira hacia donde va (solo al dibujar)
	draw_sprite_ext(spr_bear_missile, 0, x, y, owner.sprite_scale, owner.sprite_scale, point_direction(0, 0, vx, vy), c_white, 1.0);
	}

/* Copyright 2024 Springroll Games / Yosi */