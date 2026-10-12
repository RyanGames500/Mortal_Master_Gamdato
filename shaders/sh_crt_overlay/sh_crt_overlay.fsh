varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_scan;   // fuerza de las scanlines
uniform float u_vig;    // fuerza de la viñeta
uniform float u_rows;   // alto de la imagen en píxeles (camera_height)

void main()
{
    vec2 c = v_vTexcoord - 0.5;
    float d = dot(c, c);

    // Scanlines: una de cada 3 filas
    float row = floor(v_vTexcoord.y * u_rows);
    float a_scan = u_scan * step(2.0, mod(row, 3.0));

    // Viñeta
    float a_vig = u_vig * smoothstep(0.10, 0.50, d);

    // Las dos capas oscuras combinadas
    float a = 1.0 - (1.0 - a_scan) * (1.0 - a_vig);

    gl_FragColor = vec4(0.0, 0.0, 0.0, a);
}