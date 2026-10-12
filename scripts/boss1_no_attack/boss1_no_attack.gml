/*
Ataque vacío: para personajes que no tienen ese ataque (aéreo, agachado...).
Termina en el mismo frame sin crear ningún hitbox.
Aplica la misma física que un ataque aéreo ese frame para que no se note un tirón.
*/
function boss1_no_attack(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			// Gravedad solo si está en el aire (igual que blocky_light_aerial)
			if (bbox_bottom < obj_ground.y)
				{
				vsp += grav;
				}
			player_move();
			attack_stop();
			}
		break;
		}
	}