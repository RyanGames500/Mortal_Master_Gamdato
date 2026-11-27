#macro CRT_SCAN_ALPHA	0.20
#macro CRT_VIGNETTE		0.55

function crt_ensure()
	{
	if (!instance_exists(obj_crt)) then instance_create_layer(0, 0, "scanlines", obj_crt);
	}

function crt_ring(_w, _h, _ia, _aa, _ib, _ab)
	{
	var _ax = _w * _ia, _ay = _h * _ia, _bx = _w * _ib, _by = _h * _ib;
	var _x1 = [_ax, _w - _ax, _w - _ax, _ax];
	var _y1 = [_ay, _ay, _h - _ay, _h - _ay];
	var _x2 = [_bx, _w - _bx, _w - _bx, _bx];
	var _y2 = [_by, _by, _h - _by, _h - _by];
	
	draw_primitive_begin(pr_trianglelist);
	for (var i = 0; i < 4; i++)
		{
		var j = (i + 1) mod 4;
		draw_vertex_color(_x1[i], _y1[i], c_black, _aa);
		draw_vertex_color(_x1[j], _y1[j], c_black, _aa);
		draw_vertex_color(_x2[j], _y2[j], c_black, _ab);
		
		draw_vertex_color(_x1[i], _y1[i], c_black, _aa);
		draw_vertex_color(_x2[j], _y2[j], c_black, _ab);
		draw_vertex_color(_x2[i], _y2[i], c_black, _ab);
		}
	draw_primitive_end();
	}