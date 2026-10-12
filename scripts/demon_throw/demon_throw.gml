function demon_throw(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_demon_throw;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup (frame 0 -> 1) y creacion del hitbox de agarre
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 24;
				
				var _hitbox = hitbox_create(130, -47, 1.2, 0.5, 0, 5);
				_hitbox.grab = true;
				_hitbox.hitstun = 60;
				_hitbox.grounded_only = true;
				}
			
			player_move();
			}
		break;
		
		//Agarre activo y endlag si falla
		case 1:
			{
			attack_frame--;
			
			//Si el agarre conecto, pasa a la fase de cargar y lanzar
			if (attack_connected)
				{
				anim_frame = 2;
				attack_phase = 2;
				attack_frame = 24;
				break;
				}
			
			player_move();
			
			//Stop
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Carga y lanzamiento (frames 2 a 7)
		case 2:
			{
			attack_frame--;
			
			//Buscar al otro jugador
			var _other_player = noone;
			with (obj_player)
				{
				if (id != other.id)
					{
					_other_player = id;
					break;
					}
				}
			
			//Frame de Demon segun el tiempo
			if (attack_frame > 20)      then anim_frame = 2;
			else if (attack_frame > 16) then anim_frame = 3;
			else if (attack_frame > 11) then anim_frame = 4;
			else if (attack_frame > 6)  then anim_frame = 5;
			else if (attack_frame > 2)  then anim_frame = 6;
			else                             anim_frame = 7;
			
			//Posicion del rival en cada frame (centro, en pixeles del sprite de 146x96, origen x = 73, pies = fila 95)
			var _vx = [95, 100.5, 82, 67.5, 43.5, 39];
			var _vy = [63.5, 54, 37.5, 43.5, 51.5, 82.5];
			var _i = clamp(anim_frame - 2, 0, 5);
			
			//Ajustes finos (por si el rival no queda bien en las manos). Subir/bajar estos numeros.
			var _adj_x = 0;
			var _adj_y = 0;
			
			_other_player.x = x + ((_vx[_i] - 73) * sprite_scale * facing) + _adj_x * facing;
			_other_player.y = obj_ground.y - ((95 - _vy[_i]) * sprite_scale) + _adj_y;
			
			//Sprite del rival: lo controla este script mientras lo cargan
			var _victim_sprite = _other_player.sprites[$ "grabbed_carry"];
			if (!is_undefined(_victim_sprite))
				{
				_other_player.being_carried = true;
				_other_player.anim_sprite = _victim_sprite;
				_other_player.anim_speed = 0;
				_other_player.anim_frame = clamp(_i, 0, sprite_get_number(_victim_sprite) - 1);
				}
			
			//Golpe final contra el piso
			if (attack_frame <= 2 && attack_connected)
				{
				attack_connected = false;
				_other_player.being_carried = false;
				
				//El rival queda apoyado en el piso
				_other_player.y = ceil(obj_ground.y - (_other_player.bbox_bottom - _other_player.y));
				
				//Hitbox justo sobre el rival (calculado desde su posicion real)
				var _hx = (_other_player.x - x) * facing;
				var _hy = _other_player.y - y;
				var _hitbox = hitbox_create(_hx, _hy, 1.2, 1.5, 22, 4);
				_hitbox.knockback = -12;
				_hitbox.launch_speed = 12;
				_hitbox.knockdown = true;
				_hitbox.hitlag = 13;
				
				attack_phase = 3;
				attack_frame = 18;
				}
			
			player_move();
			}
		break;
		
		//Endlag del lanzamiento
		case 3:
			{
			attack_frame--;
			
			anim_frame = 7;
			player_move();
			
			//Stop
			if (attack_frame == 0)
				{
				attack_stop();
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */