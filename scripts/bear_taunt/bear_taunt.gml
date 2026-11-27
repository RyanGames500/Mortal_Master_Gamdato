function bear_taunt(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_bear_taunt;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 60;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			var _frames = 20;
			anim_frame = clamp((60 - attack_frame) div 3, 0, _frames - 1);
			
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