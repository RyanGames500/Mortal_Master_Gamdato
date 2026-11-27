///@category GGMR
///@param {int} connection_id		The connection to check
function ggmr_net_connection_silence()
	{
	with (obj_ggmr_net)
		{
		var _id = argument[0];
		
		if (is_undefined(_id) || _id == -1 || _id == noone) then return 0;
		
		var _data = net_connections[? string(_id)];
		
		if (is_undefined(_data)) then return 0;
		
		return (current_time - _data.last_packet_timestamp);
		}
	return 0;
	}