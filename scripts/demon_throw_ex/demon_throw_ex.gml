function demon_throw_ex(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_demon_throw;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;		// startup mas rapido que el normal (6)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup y hitbox de agarre (mas alcance, hitstun largo)
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 24;
				
				var _hitbox = hitbox_create(145, -47, 1.4, 0.5, 0, 5);
				_hitbox.grab = true;
				_hitbox.hitstun = 90;
				_hitbox.grounded_only = true;
				}
			
			player_move();
			}
		break;
		
		//Agarre activo y endlag si falla
		case 1:
			{
			attack_frame--;
			
			if (attack_connected)
				{
				anim_frame = 2;
				attack_phase = 2;
				attack_frame = 24;
				break;
				}
			
			player_move();
			
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Carga con DRENAJE continuo y estrellada final
		case 2:
			{
			attack_frame--;
			
			var _other_player = noone;
			with (obj_player)
				{
				if (id != other.id)
					{
					_other_player = id;
					break;
					}
				}
			
			//Si el rival rompio el agarre (tech) se suelta y se aborta
			if (_other_player != noone && attack_frame < 23 && _other_player.state != PLAYER_STATE.grabbed)
				{
				_other_player.being_carried = false;
				attack_connected = false;
				anim_frame = 7;
				attack_phase = 3;
				attack_frame = 18;
				break;
				}
			
			//Brillo rojo del EX durante toda la secuencia
			ex_flash = max(ex_flash, 10);
			
			//Frame de Demon segun el tiempo
			if (attack_frame > 20)      then anim_frame = 2;
			else if (attack_frame > 16) then anim_frame = 3;
			else if (attack_frame > 11) then anim_frame = 4;
			else if (attack_frame > 6)  then anim_frame = 5;
			else if (attack_frame > 2)  then anim_frame = 6;
			else                             anim_frame = 7;
			
			//Posicion del rival en cada frame (igual que el normal)
			var _vx = [95, 100.5, 82, 67.5, 43.5, 39];
			var _vy = [63.5, 54, 37.5, 43.5, 51.5, 82.5];
			var _i = clamp(anim_frame - 2, 0, 5);
			
			var _adj_x = 0;
			var _adj_y = 0;
			
			_other_player.x = x + ((_vx[_i] - 73) * sprite_scale * facing) + _adj_x * facing;
			_other_player.y = obj_ground.y - ((95 - _vy[_i]) * sprite_scale) + _adj_y;
			
			var _victim_sprite = _other_player.sprites[$ "grabbed_carry"];
			if (!is_undefined(_victim_sprite))
				{
				_other_player.being_carried = true;
				_other_player.anim_sprite = _victim_sprite;
				_other_player.anim_speed = 0;
				_other_player.anim_frame = clamp(_i, 0, sprite_get_number(_victim_sprite) - 1);
				}
			
			//--- DRENAJE continuo: cada 3 frames quita 2 y cura 1 (sin hitlag, sin sonido, sin shake, sin contar como hit) ---
			if (attack_connected && attack_frame <= 21 && attack_frame >= 6 && (attack_frame mod 3) == 0)
				{
				player_damage(2, _other_player);
				hp_heal(1);
				
				//Si murio drenado: se suelta y cae a knockdown
				if (_other_player.hp <= 0)
					{
					_other_player.being_carried = false;
					_other_player.y = ceil(obj_ground.y - (_other_player.bbox_bottom - _other_player.y));
					with (_other_player)
						{
						player_state_set(PLAYER_STATE.knockdown);
						anim_frame = 0;
						hsp = 10 * other.facing;
						vsp = -12;
						}
					attack_connected = false;
					anim_frame = 7;
					attack_phase = 3;
					attack_frame = 18;
					obj_game.cam_shake = max(obj_game.cam_shake, 8);
					break;
					}
				}
			
			//--- ESTRELLADA FINAL: el unico golpe que se siente, con la cura grande ---
			if (attack_frame <= 2 && attack_connected)
				{
				attack_connected = false;
				_other_player.being_carried = false;
				_other_player.y = ceil(obj_ground.y - (_other_player.bbox_bottom - _other_player.y));
				
				with (_other_player)
					{
					player_face_opponent();
					}
				
				var _hx = (_other_player.x - x) * facing;
				var _hy = _other_player.y - y;
				var _hitbox = hitbox_create(_hx, _hy, 1.3, 1.5, 18, 4);
				_hitbox.knockback = -12;
				_hitbox.launch_speed = 14;
				_hitbox.knockdown = true;
				_hitbox.hitstun = 40;
				_hitbox.hitlag = 18;
				
				hp_heal(6);
				obj_game.cam_shake = max(obj_game.cam_shake, 12);
				
				attack_phase = 3;
				attack_frame = 18;
				}
			
			player_move();
			}
		break;
		
		//Endlag
		case 3:
			{
			attack_frame--;
			
			anim_frame = 7;
			player_move();
			
			if (attack_frame == 0)
				{
				attack_stop();
				}
			}
		break;
		}
	}