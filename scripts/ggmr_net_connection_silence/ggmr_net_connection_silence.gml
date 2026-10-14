///@category GGMR
///@param {int} connection_id		The connection to check
/*
Returns the amount of time (in milliseconds) since a packet was received on the given connection.
This is mainly intended for detecting if another player has disconnected from the network.
*/
function ggmr_net_connection_silence()
	{
	with (obj_ggmr_net)
		{
		var _id = argument[0];
		
		// 1. Si la conexión es nula, vacía o inválida, retornar 0 para evitar el crash
		if (is_undefined(_id) || _id == -1 || _id == noone) then return 0;
		
		var _data = net_connections[? string(_id)];
		
		// 2. Si la estructura de la conexión no existe dentro del mapa, retornar 0
		if (is_undefined(_data)) then return 0;
		
		return (current_time - _data.last_packet_timestamp);
		}
	return 0;
	}