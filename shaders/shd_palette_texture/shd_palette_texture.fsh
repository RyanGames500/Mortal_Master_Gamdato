/*
Replaces colors in the texture based on the given palette arrays. Ignores alpha values when replacing colors.
*/
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D palette_texture;
uniform float column;
uniform float texel_height;
uniform vec4 uvs;

const float tolerance = 0.05;

void main()
	{
	//Check if the color is any of the base colors
	gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	
	//Supports up to 10 colors by default
	for (float i = 0.; i < 10.; i += 1.)
		{
		//Stop checking after you have moved past the area the sprite occupies on the texture
		float offset = (i * texel_height);
		if (offset >= uvs.w) break;
		
		//If the color is close enough to the base color...
		if (gl_FragColor.a != 0. && abs(distance(gl_FragColor.rgb, texture2D(palette_texture, vec2(uvs.x, uvs.y + offset)).rgb)) <= tolerance)
			{
			//...replace it with the swap color
			gl_FragColor.rgb = texture2D(palette_texture, vec2(uvs.x + column, uvs.y + offset)).rgb + (gl_FragColor.rgb - texture2D(palette_texture, vec2(uvs.x, uvs.y + offset)).rgb);
			break;
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */