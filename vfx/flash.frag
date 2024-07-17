uniform vec4 flashCol = vec4(1.0);
uniform float amount = 0.0;

vec4 effect(vec4 col, Image tex, vec2 uv, vec2 pixCoord)
{
  vec4 texCol = Texel(tex, uv);
  return mix(texCol, flashCol, amount * texCol.a);
}
