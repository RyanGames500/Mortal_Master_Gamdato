varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_scan;
uniform float u_vig;
uniform float u_aber;
uniform float u_rows;

void main()
{
    vec2 uv = v_vTexcoord;
    vec2 c = uv - 0.5;
    float d = dot(c, c);

    vec2 off = c * d * u_aber;
    float r = texture2D(gm_BaseTexture, uv + off).r;
    vec4 g = texture2D(gm_BaseTexture, uv);
    float b = texture2D(gm_BaseTexture, uv - off).b;
    vec3 col = vec3(r, g.g, b);

    float row = floor(uv.y * u_rows);
    col *= 1.0 - u_scan * step(2.0, mod(row, 3.0));

    col *= 1.0 - u_vig * smoothstep(0.10, 0.50, d);

    gl_FragColor = vec4(col, g.a);
}