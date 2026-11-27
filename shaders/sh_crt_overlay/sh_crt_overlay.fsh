varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_scan;
uniform float u_vig;
uniform float u_rows;

void main()
{
    vec2 c = v_vTexcoord - 0.5;
    float d = dot(c, c);

    float row = floor(v_vTexcoord.y * u_rows);
    float a_scan = u_scan * step(2.0, mod(row, 3.0));

    float a_vig = u_vig * smoothstep(0.10, 0.50, d);

    float a = 1.0 - (1.0 - a_scan) * (1.0 - a_vig);

    gl_FragColor = vec4(0.0, 0.0, 0.0, a);
}