/*
Super 2 de Joe: FURIA DEL CAMPEON (nuestro). Doble media luna + heavy, toda la barra (300).
Estilo "Blazin Move": coreografia fluida de golpes; justo antes del golpe final el rival queda
congelado una pausa corta (SUPER_CHARGE_FRAMES) mientras Joe carga el puño, y sale el golpe de fuego.
Solo continua si el primer golpe CONECTA limpio. Si lo bloquean o falla, se corta y Joe queda castigable.
Durante la coreografia el rival no puede morir (super_lock): se queda en 1 de vida hasta el golpe final.
Fases: 0 = carga, 1 = embestida, 2 = primer golpe, 3 = coreografia (linea de tiempo), 4 = pausa antes del golpe final,
       5 = golpe final de fuego, 6 = recuperacion.
*/
function blocky_super_cine(_override_phase)
	{
	// Coreografia: super_ev(frame, sprite, pose, avance, golpe)
	static _tl = [
		super_ev(0,  spr_blocky_light_ground,  5, 5),
		super_ev(4,  spr_blocky_light_ground,  7),
		super_ev(8,  spr_blocky_light_ground,  8),
		super_ev(10, spr_blocky_light_ground,  9, 0, [110, -54, 2.0, 0.8, 7, 0]),
		super_ev(14, spr_blocky_light_ground, 12, 4),
		super_ev(20, spr_blocky_light_ground, 13, 0, [100, -40, 2.0, 0.8, 7, 0]),
		super_ev(24, spr_blocky_light_ground2, 5, 4),
		super_ev(28, spr_blocky_light_ground2, 7),
		super_ev(32, spr_blocky_light_ground2, 8, 0, [120, -4, 2.0, 1.2, 7, 0]),
		super_ev(36, spr_blocky_light_ground2, 12),
		super_ev(40, spr_blocky_light_ground2, 13, 3),
		super_ev(44, spr_blocky_light_ground2, 14, 0, [110, 0, 2.0, 1.2, 9, 12])
	];
	
	var _charge_len = SUPER_CHARGE_FRAMES;		// pausa antes del golpe final (macro en scr_super)
	
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	if (_phase >= 0 && _phase <= 5) then vsp = 0;		// secuencia en el piso: nada lo eleva
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blocky_super_fist;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(90, 255, 120);
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		// Carga corta (despues de la pausa)
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_sprite = spr_blocky_runpunch;
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 18;
				hsp = 30 * facing;
				vsp = 0;
				
				var _dust = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_dust.sprite_index = spr_effect_step_dust;
				_dust.image_xscale = facing;
				_dust.anim_speed   = 0.2;
				_dust.lifetime     = sprite_get_number(spr_effect_step_dust) / _dust.anim_speed;
				_dust.owner        = id;
				}
			
			player_move();
			}
		break;
		
		// Embestida: corre hasta quedar cerca del rival y tira el primer golpe (jab)
		case 1:
			{
			attack_frame--;
			
			var _ox = x + (400 * facing);
			with (obj_player)
				{
				if (id != other.id) then _ox = x;
				}
			
			if (abs(_ox - x) < 120 || attack_frame <= 0)
				{
				hsp = 0;
				attack_phase = 2;
				attack_frame = 14;
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla o lo bloquean, queda vendido
				anim_sprite = spr_blocky_light_ground;
				anim_frame = 2;
				
				var _op = hitbox_create(110, -54, 2.0, 0.8, 7, 8);
				_op.hitlag = 4;
				_op.knockback = 3;
				_op.hitstun = 60;
				}
			
			player_move();
			}
		break;
		
		// Primer golpe: si conecta limpio sigue la coreografia; si lo bloquean o falla, se corta
		case 2:
			{
			attack_frame--;
			hsp = lerp(hsp, 0, 0.2);
			
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					attack_phase = 3;
					attack_frame = 0;		// aqui cuenta hacia arriba: tiempo de la coreografia
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta el golpe final
					}
				else
					{
					anim_sprite = spr_blocky_super_fist;
					anim_frame = 7;
					attack_phase = 6;
					attack_frame = 50;
					}
				}
			else if (attack_frame <= 0)
				{
				anim_sprite = spr_blocky_super_fist;
				anim_frame = 7;
				attack_phase = 6;
				attack_frame = 50;
				}
			
			player_move();
			}
		break;
		
		// Coreografia: poses y golpes salen de la tabla, uno tras otro sin esperar recuperaciones
		case 3:
			{
			super_timeline_run(_tl, attack_frame);
			attack_frame++;
			hsp = lerp(hsp, 0, 0.2);
			
			if (attack_frame > 50)
				{
				// Terminaron los golpes: el rival queda congelado y Joe carga el puño
				attack_phase = 4;
				attack_frame = _charge_len;
				anim_sprite = spr_blocky_super_fist;
				anim_frame = 0;
				hsp = 0;
				}
			
			player_move();
			}
		break;
		
		// Pausa corta antes del golpe final: el rival congelado, Joe carga el puño
		case 4:
			{
			attack_frame--;
			
			// el rival queda congelado
			with (obj_player)
				{
				if (id != other.id) then hitlag_frame = max(hitlag_frame, 2);
				}
			
			if (attack_frame == ((_charge_len * 2) div 3)) then anim_frame = 1;
			if (attack_frame == (_charge_len div 3)) then anim_frame = 2;
			
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 5;
				attack_frame = 24;
				attack_connected = false;
				super_lock = false;			// desde aqui el golpe final SI puede matar
				hsp = 20 * facing;
				
				// Golpe final de fuego: manda a volar
				var _fin = hitbox_create(190, -40, 2.8, 1.6, 40, 22);
				_fin.hitlag = 12;
				_fin.launch_speed = 24;
				_fin.high = true;
				_fin.knockback = 34;
				_fin.knockdown = true;
				_fin.hitstun = 70;
				
				super_hit_fx = 8;			// destello al soltar el golpe
				obj_game.cam_shake = max(obj_game.cam_shake, 10);
				}
			
			player_move();
			}
		break;
		
		// Golpe final: el fuego se anima; al conectar explota
		case 5:
			{
			attack_frame--;
			
			anim_frame = 3 + (floor((24 - attack_frame) / 5) mod 4);
			
			hsp = lerp(hsp, 0, 0.06);
			
			if (attack_connected)
				{
				var _fx = instance_create_layer(x + (170 * facing), y, "VFX_Layer", obj_vfx);
				_fx.sprite_index = spr_blocky_buster_wolf_explosion;
				_fx.image_xscale = 4 * facing;
				_fx.image_yscale = 4;
				_fx.anim_speed   = 0.5;
				_fx.lifetime     = sprite_get_number(spr_blocky_buster_wolf_explosion) / _fx.anim_speed;
				_fx.owner        = id;
				
				super_hit_fx = 16;
				obj_game.cam_shake = max(obj_game.cam_shake, 24);
				
				anim_frame = 7;
				attack_phase = 6;
				attack_frame = 40;
				super_invuln = false;
				}
			else if (attack_frame <= 0)
				{
				anim_frame = 7;
				attack_phase = 6;
				attack_frame = 50;
				super_invuln = false;
				}
			
			player_move();
			}
		break;
		
		// Recuperacion (vulnerable)
		case 6:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 8;
			
			hsp = lerp(hsp, 0, 0.12);
			player_move();
			
			if (attack_frame <= 0)
				{
				ex_glow_color = make_colour_rgb(255, 40, 40);
				attack_stop();
				break;
				}
			}
		break;
		}
	}