function scar_throw(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//--- INIT ---
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_special1_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//--- STARTUP ---
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 30;
				
				var _hitbox = hitbox_create(98, -47, 1, 0.5, 0, 5);
				_hitbox.grab = true;
				_hitbox.hitstun = 120;
				_hitbox.grounded_only = true;
				}
			
			player_move();
			}
		break;
		
		//--- DETECCION Y CAMBIO DE ESTADO ---
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 26) then anim_frame = 4;
			if (attack_frame == 13) then anim_frame = 5;
			
			if (attack_connected)
				{
				anim_frame = 6;
				attack_phase = 2;
				attack_frame = 80;
				
				var _other_player = noone;
				with (obj_player)
					{
					if (id != other.id)
						{
						_other_player = id;
						break;
						}
					}
				if (_other_player != noone)
					{
					_other_player.being_carried = true;
					_other_player.hsp = 0;
					_other_player.vsp = 0;
					}
				
				if (stick_check_direction(STICK_DIR.backward_any))
					{
					facing *= -1;
					x += -20 * facing;
					}
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
		
		//--- MULTI-HITS Y SECUENCIA DE GOLPES ---
		case 2:
			{
			attack_frame--;
			
			hsp = 0;
			vsp = 0;
			
			var _other_player = noone;
			with (obj_player)
				{
				if (id != other.id)
					{
					_other_player = id;
					break;
					}
				}
			
			// Si el rival rompio el agarre (tech) ya no esta en grabbed: se aborta la secuencia
			if (_other_player != noone && attack_frame < 79 && _other_player.state != PLAYER_STATE.grabbed)
				{
				_other_player.being_carried = false;
				attack_connected = false;
				anim_frame = 27;
				attack_phase = 3;
				attack_frame = 20;
				break;
				}
			
			// Retroceso cosmetico del rival durante 3 frames despues de cada golpe
			var _recoil = 0;
			if ((attack_frame <= 62 && attack_frame > 59)
			 || (attack_frame <= 42 && attack_frame > 39)
			 || (attack_frame <= 22 && attack_frame > 19))
				{
				_recoil = 4;
				}
			
			if (_other_player != noone)
				{
				_other_player.being_carried = true;
				_other_player.hsp = 0;
				_other_player.vsp = 0;
				_other_player.x = x + ((105 + _recoil) * facing);
				_other_player.y = y - 28;
				
				// el rival mira hacia Scar con el mecanismo del propio motor
				with (_other_player)
					{
					player_face_opponent();
					}
				}
			
			if (attack_frame == 74) then anim_frame = 7;
			if (attack_frame == 68) then anim_frame = 8;
			
			// GOLPE 1
			if (attack_frame == 62)
				{
				anim_frame = 11;
				if (_other_player != noone)
					{
					player_damage(4, _other_player);
					_other_player.hitstun = 60;
					hitlag_frame = 5;
					_other_player.hitlag_frame = 5;
					obj_game.cam_shake = max(obj_game.cam_shake, 3);
					hit_sfx_play(snd_hit_light_3);
					}
				}
			
			if (attack_frame == 54) then anim_frame = 13;
			if (attack_frame == 48) then anim_frame = 14;
			
			// GOLPE 2
			if (attack_frame == 42)
				{
				anim_frame = 16;
				if (_other_player != noone)
					{
					player_damage(10, _other_player);
					_other_player.hitstun = 60;
					hitlag_frame = 6;
					_other_player.hitlag_frame = 6;
					obj_game.cam_shake = max(obj_game.cam_shake, 4);
					hit_sfx_play(snd_hit_light_3);
					}
				}
			
			if (attack_frame == 34) then anim_frame = 18;
			if (attack_frame == 28) then anim_frame = 19;
			
			// GOLPE 3
			if (attack_frame == 22)
				{
				anim_frame = 21;
				if (_other_player != noone)
					{
					player_damage(4, _other_player);
					_other_player.hitstun = 60;
					hitlag_frame = 7;
					_other_player.hitlag_frame = 7;
					obj_game.cam_shake = max(obj_game.cam_shake, 5);
					hit_sfx_play(snd_hit_light_3);
					}
				}
			
			if (attack_frame == 16) then anim_frame = 23;
			if (attack_frame == 10) then anim_frame = 25;
			
			// IMPACTO FINAL Y SOLTAR RIVAL
			if (attack_frame == 0)
				{
				anim_frame = 27;
				attack_connected = false;
				obj_game.cam_shake = max(obj_game.cam_shake, 8);
				
				var _rival_muerto = false;
				var _hx = 85;
				var _hy = -35;
				
				if (_other_player != noone)
					{
					_other_player.being_carried = false;
					_other_player.y = ceil(obj_ground.y - (_other_player.bbox_bottom - _other_player.y));
					
					_hx = (_other_player.x - x) * facing;
					_hy = (_other_player.y - y) - 35;
					
					_rival_muerto = (_other_player.hp <= 0);
					}
				
				if (_rival_muerto)
					{
					// KO: el hitbox ya no llega (la ronda termino), asi que lo mandamos
					// nosotros a knockdown. El estado knockdown/acostado hace el resto.
					with (_other_player)
						{
						player_state_set(PLAYER_STATE.knockdown);
						anim_frame = 0;
						hsp = 10 * other.facing;
						vsp = -12;
						}
					}
				else
					{
					var _hitbox = hitbox_create(_hx, _hy, 1.4, 1.5, 15, 4);
					_hitbox.grab = false;
					_hitbox.knockback = 18;
					_hitbox.launch_speed = 10;
					_hitbox.knockdown = true;
					_hitbox.hitstun = 40;
					_hitbox.hitlag = 13;
					}
				
				attack_phase = 3;
				attack_frame = 20;
				}
			}
		break;
		
		//--- ENDLAG ---
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 29;
			if (attack_frame == 12) then anim_frame = 30;
			if (attack_frame == 8)  then anim_frame = 31;
			if (attack_frame == 4)  then anim_frame = 32;
			
			if (attack_frame == 0)
				{
				attack_stop();
				}
			}
		break;
		}
	}