varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D palette_texture;
uniform float column;
uniform float texel_height;
uniform vec4 uvs;

const float tolerance = 0.05;

void main()
	{
	gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	
	for (float i = 0.; i < 10.; i += 1.)
		{
		float offset = (i * texel_height);
		if (offset >= uvs.w) break;
		
		if (gl_FragColor.a != 0. && abs(distance(gl_FragColor.rgb, texture2D(palette_texture, vec2(uvs.x, uvs.y + offset)).rgb)) <= tolerance)
			{
			gl_FragColor.rgb = texture2D(palette_texture, vec2(uvs.x + column, uvs.y + offset)).rgb + (gl_FragColor.rgb - texture2D(palette_texture, vec2(uvs.x, uvs.y + offset)).rgb);
			break;
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */