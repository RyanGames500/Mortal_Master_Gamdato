function bear_taunt(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_bear_taunt;	// sprite nuestro: la hoja de la risa (20 cuadros)
			anim_frame = 0;
			anim_speed = 0;		// Determinista: cero image_speed para el rollback
			
			attack_frame = 60;	// duración total: 20 cuadros x 3 frames cada uno
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		// Risa: sin hitbox, sin invulnerabilidad. Si lo golpean, el golpe la cancela solo.
		case 0:
			{
			attack_frame--;
			
			var _frames = 20;	// cuadros de la hoja
			anim_frame = clamp((60 - attack_frame) div 3, 0, _frames - 1);
			
			player_move();
			
			// Fin de la burla
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}