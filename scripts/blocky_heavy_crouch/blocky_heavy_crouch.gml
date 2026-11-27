function blocky_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blocky_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			if (attack_frame == 5)
				{
				anim_frame = 1;
				
				if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_whoosh_heavy);
				}
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 5) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 30;
				hsp = 2 * facing;
				
				var _hitbox = hitbox_create(60, -90, 0.7, 1.2, 14, 5);
				_hitbox.hitlag = 7;
				_hitbox.launch_speed = 30;
				_hitbox.knockback = 15;
				_hitbox.knockdown = true;
				_hitbox.fatality = FATALITY.decapitar;				
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 26) then anim_frame = 3;
			if (attack_frame == 20) then anim_frame = 4;
			if (attack_frame == 14) then anim_frame = 5;
			if (attack_frame == 7) then anim_frame = 6;
			
			if (attack_frame == 26)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */