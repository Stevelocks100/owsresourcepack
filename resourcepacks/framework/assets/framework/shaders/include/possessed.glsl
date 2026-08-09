vec2[] OverlayChecks = vec2[](
    vec2(-1,1),
    vec2(0,1),
    vec2(1,1),
    vec2(-1,0),
    //vec2(0,0),
    vec2(1,0),
    vec2(-1,-1),
    vec2(0,-1),
    vec2(1,-1)
);

bool isOverlay(sampler2D tex, vec2 UV) {
    vec2 tex_size = textureSize(tex,0);
    vec4 check = round(texture(tex,UV + vec2(0,0)/tex_size) * vec4(255,255,255,100));
    if (check == vec4(160,92,179,69)) return true;

    for (int i = 0; i < 8; i++) {
        check = round(texture(tex,UV + OverlayChecks[i]/tex_size) * vec4(255,255,255,100));
        if (check == vec4(160,92,179,69)) return true;
    }
    
    return false;

    
}


//	Classic Perlin 2D Noise 
//	by Stefan Gustavson (https://github.com/stegu/webgl-noise)
//
vec4 permute_possessed(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}

vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute_possessed(permute_possessed(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

vec4 possessed_overlay(vec2 uv, float iTime, sampler2D tex, float vertex_distance, vec2 fragcoord) {

    vec4 color = vec4(0);
    vec2 layer_offset = vec2(256,0);
    vec2 tex_size = textureSize(tex,0);

    float intensity = 1.0 - clamp(vertex_distance, 0.0, 30.0) / 30.0;
    intensity = pow(intensity,1.5);
    for (int i = 0; i < 4; i++) {
        if (float(i) >= intensity * 6.0)
        continue;

        vec2 shake = vec2(
            cnoise(vec2(float(i) * 256,iTime*7)),
            cnoise(vec2(float(i) * 144,iTime*7))
        ) * (intensity + 0.2);

        float layerFade = pow(clamp(intensity * 6.0 - float(i), 0.0, 1.0),3);

        vec4 tex_color = texture(tex, uv + (layer_offset*(i+1))/tex_size + (shake * 2 / tex_size) );
        if (tex_color.a > color.a && tex_color.a > 0.1) color = tex_color * vec4(1,1,1,layerFade);
    }

    if (color.a > 0.01) {
        color.rgb = mix(color.rgb,vec3(1,0,0),pow(intensity * distance(fragcoord,vec2(0.5)),2));
    }


    return color;
    
}