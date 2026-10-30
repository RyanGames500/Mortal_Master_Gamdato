varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_scan;   // fuerza de las scanlines (0 = apagadas)
uniform float u_vig;    // fuerza de la viñeta en las esquinas
uniform float u_aber;   // separación de color en los bordes
uniform float u_rows;   // alto de la imagen en píxeles (camera_height)

void main()
{
    vec2 uv = v_vTexcoord;
    vec2 c = uv - 0.5;
    float d = dot(c, c);

    // Aberración cromática: solo se nota hacia los bordes, el centro queda limpio
    vec2 off = c * d * u_aber;
    float r = texture2D(gm_BaseTexture, uv + off).r;
    vec4 g = texture2D(gm_BaseTexture, uv);
    float b = texture2D(gm_BaseTexture, uv - off).b;
    vec3 col = vec3(r, g.g, b);

    // Scanlines: una de cada 3 filas, alineadas con tu escala de píxel (6 es múltiplo de 3)
    float row = floor(uv.y * u_rows);
    col *= 1.0 - u_scan * step(2.0, mod(row, 3.0));

    // Viñeta
    col *= 1.0 - u_vig * smoothstep(0.10, 0.50, d);

    gl_FragColor = vec4(col, g.a);
}