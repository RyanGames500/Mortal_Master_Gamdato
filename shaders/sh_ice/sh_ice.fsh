varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vWorld;

uniform vec2 u_center;
uniform float u_radius;
uniform float u_flat;

void main()
{
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
    if (col.a < 0.01) discard;
    if (distance(v_vWorld, u_center) > u_radius) discard;

    if (u_flat > 0.5)
    {
        gl_FragColor = vec4(0.67, 1.0, 0.82, 0.82 * v_vColour.a);
        return;
    }

    float l = dot(col.rgb, vec3(0.3, 0.59, 0.11));
    l = min(1.0, l * 1.15 + 0.12);
    vec3 c0 = vec3(0.04, 0.22, 0.20);
    vec3 c1 = vec3(0.12, 0.55, 0.43);
    vec3 c2 = vec3(0.43, 0.90, 0.71);
    vec3 c3 = vec3(0.88, 1.00, 0.94);
    vec3 ice;
    if (l < 0.35)      ice = mix(c0, c1, l / 0.35);
    else if (l < 0.65) ice = mix(c1, c2, (l - 0.35) / 0.30);
    else               ice = mix(c2, c3, (l - 0.65) / 0.35);
    gl_FragColor = vec4(ice, col.a * v_vColour.a);
}