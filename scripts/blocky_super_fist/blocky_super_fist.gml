/*
Super 1 de Joe: GRAN PUÑO (nuestro). Doble media luna + medium, cuesta 2 barras.
Usa spr_blocky_super_fist: frames 0-2 = carga, 3-6 = puño de fuego, 7-8 = recuperacion.
Fases: 0 = carga corta, 1 = embestida con puño de fuego, 2 = recuperacion.
Invulnerable hasta la recuperacion; si falla, la recuperacion es larga y castigable.
*/
function blocky_super_fist(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
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
			super_invuln = true;
			ex_glow_color = make_colour_rgb(255, 140, 40);
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			}
		break;
		
		// Carga corta (despues de la pausa): el puño brilla en el hombro
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 26;
				
				hsp = 26 * facing;
				vsp = -1;
				
				var _dust = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
				_dust.sprite_index = spr_effect_step_dust;
				_dust.image_xscale = facing;
				_dust.anim_speed   = 0.2;
				_dust.lifetime     = sprite_get_number(spr_effect_step_dust) / _dust.anim_speed;
				_dust.owner        = id;
				obj_game.cam_shake = max(obj_game.cam_shake, 8);
				
				// Puño de fuego: hitbox grande, mucho daño y manda a volar
				var _hitbox = hitbox_create(190, -6, 2.6, 1.3, 45, 26);
				_hitbox.hitlag = 22;
				_hitbox.launch_speed = 22;
				_hitbox.high = true;
				_hitbox.knockback = 30;
				_hitbox.knockdown = true;
				_hitbox.hitstun = 60;
				}
			
			player_move();
			}
		break;
		
		// Embestida: el fuego se anima en bucle; al conectar explota, si falla termina con recuperacion larga
		case 1:
			{
			attack_frame--;
			
			anim_frame = 3 + (floor((26 - attack_frame) / 5) mod 4);
			
			hsp = lerp(hsp, 0, 0.04);
			
			if (attack_connected)
				{
				var _fx = instance_create_layer(x + (150 * facing), y, "VFX_Layer", obj_vfx);
				_fx.sprite_index = spr_blocky_buster_wolf_explosion;
				_fx.image_xscale = 3 * facing;
				_fx.image_yscale = 3;
				_fx.anim_speed   = 0.5;
				_fx.lifetime     = sprite_get_number(spr_blocky_buster_wolf_explosion) / _fx.anim_speed;
				_fx.owner        = id;
				
				obj_game.cam_shake = max(obj_game.cam_shake, 16);
				
				anim_frame = 7;
				attack_phase = 2;
				attack_frame = 28;
				super_invuln = false;
				}
			else if (attack_frame <= 0)
				{
				anim_frame = 7;
				attack_phase = 2;
				attack_frame = 40;
				super_invuln = false;
				}
			
			player_move();
			}
		break;
		
		// Recuperacion (vulnerable)
		case 2:
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