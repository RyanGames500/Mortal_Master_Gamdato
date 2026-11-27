///@category Buffers
///@param {buffer} buffer					The buffer to write to
///@param {string} name						The name of the variable
///@param {int|buffer_type} type			The data type of the variable
///@param {any} value						The variable's current value
///@param {buffer_type} [inner_type]    	The data type of any data inside the variable (if the variable is a data structure)
function buffer_write_var_custom()
	{
    var _b = argument[0];
	var _name = argument[1];
	var _type = argument[2];
	var _val = argument[3];
	var _inner = argument_count > 4 ? argument[4] : undefined;
	
	buffer_write(_b, buffer_string, _name);
	
	switch (_type)
	    {
	    case buffer_custom_undefined:
    		buffer_write(_b, buffer_s8, buffer_custom_undefined);
    		buffer_write(_b, buffer_u8, 0);
    	break;
		
    	case buffer_custom_array:
			buffer_write(_b, buffer_s8, buffer_custom_array);
			buffer_write(_b, buffer_s8, is_undefined(_inner) ? buffer_custom_undefined : _inner);
    		buffer_write_array(_b, _val, _inner);
    	break;
		
    	case buffer_custom_list:
			buffer_write(_b, buffer_s8, buffer_custom_list);
			buffer_write(_b, buffer_s8, is_undefined(_inner) ? buffer_custom_undefined : _inner);
    		buffer_write_list(_b, _val, _inner);
    	break;
		
    	case buffer_custom_map:
			buffer_write(_b, buffer_s8, buffer_custom_map);
			buffer_write(_b, buffer_s8, is_undefined(_inner) ? buffer_custom_undefined : _inner);
    		buffer_write_map(_b, _val, _inner);
    	break;
		
    	case buffer_custom_struct:
			buffer_write(_b, buffer_s8, buffer_custom_struct);
			buffer_write(_b, buffer_s8, is_undefined(_inner) ? buffer_custom_undefined : _inner);
    		buffer_write_struct(_b, _val, _inner);
    	break;
		
    	default:
        	buffer_write(_b, buffer_s8, _type);
        	buffer_write(_b, _type, _val);
    	break;
	    }
	}

/* Copyright 2024 Springroll Games / Yosi */