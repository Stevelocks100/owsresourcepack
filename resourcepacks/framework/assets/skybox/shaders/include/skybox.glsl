vec4 cpermute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 ctaylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec4 cfade(vec4 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise_vec4(vec4 P){
  vec4 Pi0 = floor(P); // Integer part for indexing
  vec4 Pi1 = Pi0 + 1.0; // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec4 Pf0 = fract(P); // Fractional part for interpolation
  vec4 Pf1 = Pf0 - 1.0; // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = vec4(Pi0.zzzz);
  vec4 iz1 = vec4(Pi1.zzzz);
  vec4 iw0 = vec4(Pi0.wwww);
  vec4 iw1 = vec4(Pi1.wwww);

  vec4 ixy = cpermute(cpermute(ix) + iy);
  vec4 ixy0 = cpermute(ixy + iz0);
  vec4 ixy1 = cpermute(ixy + iz1);
  vec4 ixy00 = cpermute(ixy0 + iw0);
  vec4 ixy01 = cpermute(ixy0 + iw1);
  vec4 ixy10 = cpermute(ixy1 + iw0);
  vec4 ixy11 = cpermute(ixy1 + iw1);

  vec4 gx00 = ixy00 / 7.0;
  vec4 gy00 = floor(gx00) / 7.0;
  vec4 gz00 = floor(gy00) / 6.0;
  gx00 = fract(gx00) - 0.5;
  gy00 = fract(gy00) - 0.5;
  gz00 = fract(gz00) - 0.5;
  vec4 gw00 = vec4(0.75) - abs(gx00) - abs(gy00) - abs(gz00);
  vec4 sw00 = step(gw00, vec4(0.0));
  gx00 -= sw00 * (step(0.0, gx00) - 0.5);
  gy00 -= sw00 * (step(0.0, gy00) - 0.5);

  vec4 gx01 = ixy01 / 7.0;
  vec4 gy01 = floor(gx01) / 7.0;
  vec4 gz01 = floor(gy01) / 6.0;
  gx01 = fract(gx01) - 0.5;
  gy01 = fract(gy01) - 0.5;
  gz01 = fract(gz01) - 0.5;
  vec4 gw01 = vec4(0.75) - abs(gx01) - abs(gy01) - abs(gz01);
  vec4 sw01 = step(gw01, vec4(0.0));
  gx01 -= sw01 * (step(0.0, gx01) - 0.5);
  gy01 -= sw01 * (step(0.0, gy01) - 0.5);

  vec4 gx10 = ixy10 / 7.0;
  vec4 gy10 = floor(gx10) / 7.0;
  vec4 gz10 = floor(gy10) / 6.0;
  gx10 = fract(gx10) - 0.5;
  gy10 = fract(gy10) - 0.5;
  gz10 = fract(gz10) - 0.5;
  vec4 gw10 = vec4(0.75) - abs(gx10) - abs(gy10) - abs(gz10);
  vec4 sw10 = step(gw10, vec4(0.0));
  gx10 -= sw10 * (step(0.0, gx10) - 0.5);
  gy10 -= sw10 * (step(0.0, gy10) - 0.5);

  vec4 gx11 = ixy11 / 7.0;
  vec4 gy11 = floor(gx11) / 7.0;
  vec4 gz11 = floor(gy11) / 6.0;
  gx11 = fract(gx11) - 0.5;
  gy11 = fract(gy11) - 0.5;
  gz11 = fract(gz11) - 0.5;
  vec4 gw11 = vec4(0.75) - abs(gx11) - abs(gy11) - abs(gz11);
  vec4 sw11 = step(gw11, vec4(0.0));
  gx11 -= sw11 * (step(0.0, gx11) - 0.5);
  gy11 -= sw11 * (step(0.0, gy11) - 0.5);

  vec4 g0000 = vec4(gx00.x,gy00.x,gz00.x,gw00.x);
  vec4 g1000 = vec4(gx00.y,gy00.y,gz00.y,gw00.y);
  vec4 g0100 = vec4(gx00.z,gy00.z,gz00.z,gw00.z);
  vec4 g1100 = vec4(gx00.w,gy00.w,gz00.w,gw00.w);
  vec4 g0010 = vec4(gx10.x,gy10.x,gz10.x,gw10.x);
  vec4 g1010 = vec4(gx10.y,gy10.y,gz10.y,gw10.y);
  vec4 g0110 = vec4(gx10.z,gy10.z,gz10.z,gw10.z);
  vec4 g1110 = vec4(gx10.w,gy10.w,gz10.w,gw10.w);
  vec4 g0001 = vec4(gx01.x,gy01.x,gz01.x,gw01.x);
  vec4 g1001 = vec4(gx01.y,gy01.y,gz01.y,gw01.y);
  vec4 g0101 = vec4(gx01.z,gy01.z,gz01.z,gw01.z);
  vec4 g1101 = vec4(gx01.w,gy01.w,gz01.w,gw01.w);
  vec4 g0011 = vec4(gx11.x,gy11.x,gz11.x,gw11.x);
  vec4 g1011 = vec4(gx11.y,gy11.y,gz11.y,gw11.y);
  vec4 g0111 = vec4(gx11.z,gy11.z,gz11.z,gw11.z);
  vec4 g1111 = vec4(gx11.w,gy11.w,gz11.w,gw11.w);

  vec4 norm00 = ctaylorInvSqrt(vec4(dot(g0000, g0000), dot(g0100, g0100), dot(g1000, g1000), dot(g1100, g1100)));
  g0000 *= norm00.x;
  g0100 *= norm00.y;
  g1000 *= norm00.z;
  g1100 *= norm00.w;

  vec4 norm01 = ctaylorInvSqrt(vec4(dot(g0001, g0001), dot(g0101, g0101), dot(g1001, g1001), dot(g1101, g1101)));
  g0001 *= norm01.x;
  g0101 *= norm01.y;
  g1001 *= norm01.z;
  g1101 *= norm01.w;

  vec4 norm10 = ctaylorInvSqrt(vec4(dot(g0010, g0010), dot(g0110, g0110), dot(g1010, g1010), dot(g1110, g1110)));
  g0010 *= norm10.x;
  g0110 *= norm10.y;
  g1010 *= norm10.z;
  g1110 *= norm10.w;

  vec4 norm11 = ctaylorInvSqrt(vec4(dot(g0011, g0011), dot(g0111, g0111), dot(g1011, g1011), dot(g1111, g1111)));
  g0011 *= norm11.x;
  g0111 *= norm11.y;
  g1011 *= norm11.z;
  g1111 *= norm11.w;

  float n0000 = dot(g0000, Pf0);
  float n1000 = dot(g1000, vec4(Pf1.x, Pf0.yzw));
  float n0100 = dot(g0100, vec4(Pf0.x, Pf1.y, Pf0.zw));
  float n1100 = dot(g1100, vec4(Pf1.xy, Pf0.zw));
  float n0010 = dot(g0010, vec4(Pf0.xy, Pf1.z, Pf0.w));
  float n1010 = dot(g1010, vec4(Pf1.x, Pf0.y, Pf1.z, Pf0.w));
  float n0110 = dot(g0110, vec4(Pf0.x, Pf1.yz, Pf0.w));
  float n1110 = dot(g1110, vec4(Pf1.xyz, Pf0.w));
  float n0001 = dot(g0001, vec4(Pf0.xyz, Pf1.w));
  float n1001 = dot(g1001, vec4(Pf1.x, Pf0.yz, Pf1.w));
  float n0101 = dot(g0101, vec4(Pf0.x, Pf1.y, Pf0.z, Pf1.w));
  float n1101 = dot(g1101, vec4(Pf1.xy, Pf0.z, Pf1.w));
  float n0011 = dot(g0011, vec4(Pf0.xy, Pf1.zw));
  float n1011 = dot(g1011, vec4(Pf1.x, Pf0.y, Pf1.zw));
  float n0111 = dot(g0111, vec4(Pf0.x, Pf1.yzw));
  float n1111 = dot(g1111, Pf1);

  vec4 cfade_xyzw = cfade(Pf0);
  vec4 n_0w = mix(vec4(n0000, n1000, n0100, n1100), vec4(n0001, n1001, n0101, n1101), cfade_xyzw.w);
  vec4 n_1w = mix(vec4(n0010, n1010, n0110, n1110), vec4(n0011, n1011, n0111, n1111), cfade_xyzw.w);
  vec4 n_zw = mix(n_0w, n_1w, cfade_xyzw.z);
  vec2 n_yzw = mix(n_zw.xy, n_zw.zw, cfade_xyzw.y);
  float n_xyzw = mix(n_yzw.x, n_yzw.y, cfade_xyzw.x);
  return 2.2 * n_xyzw;
}

vec2 to_pixel_cord(vec2 texture_size, vec2 texture_cord) {
    return texture_cord * texture_size;
}

vec2 to_uv_cord(vec2 texture_size, vec2 pixel_cord) {
    return pixel_cord / texture_size;
}

vec2 cube_face(float size, float face) {
    int f = int(face);
    
    switch (f) {
        case 0: return vec2(0.0,    size);
        case 1: return vec2(size,  size);
        case 2: return vec2(size,    0.0);
        case 3: return vec2(size * 2,   0.0);
        case 4: return vec2(size * 2, size);
        case 5: return vec2(size * 3, size);
    }

    return vec2(0.0);
}

vec3 shifted_color(sampler2D Sampler, vec2 texCoord) {
    vec2 coords = vec2(0,1024)/textureSize(Sampler,0);
    return texture(Sampler,texCoord+coords).rgb;
}




vec4 skybox(sampler2D Texture, vec2 texCoord, vec3 fragmentPos, float iTime, vec4 old_color) {
    vec4 returnValue = old_color;

    vec2 texture_size = textureSize(Texture,0);
    vec2 temp_texCoord = floor(texCoord*texture_size)/texture_size;
    ivec2 pixel_coord = ivec2(floor(temp_texCoord * texture_size));
    float skybox = round(texelFetch(Texture, pixel_coord,0).a * 100);
    vec3 funny_color = vec3(round(texelFetch(Texture, pixel_coord,0).rgb * 255));
    vec3 rotate_color = vec3(1);
    float size = 512.0;

    if (skybox == 58 && funny_color.rg == vec2(69,42)) {

        // direction to face
        vec3 dir = normalize(fragmentPos.xyz);        
        vec3 absDir = abs(dir);
        float maxAxis;
        vec2 uv;
        float face = 0.0;

        
        
        // face logic
        if (absDir.x >= absDir.y && absDir.x >= absDir.z) {
            maxAxis = absDir.x;
            uv = vec2(dir.z, dir.y) / maxAxis;
            face = dir.x > 0.0 ? 0.0 : 1.0;
        } else if (absDir.y >= absDir.x && absDir.y >= absDir.z) {
            maxAxis = absDir.y;
            uv = vec2(dir.x, -dir.z) / maxAxis;
            face = dir.y > 0.0 ? 2.0 : 3.0;
        } else {
            maxAxis = absDir.z;
            uv = vec2(dir.x, dir.y) / maxAxis;
            face = dir.z > 0.0 ? 4.0 : 5.0;
        }
        
        // convert [-1,1] to [0,1]
        uv = uv * 0.5 + 0.5;
        
        // flip Y to match texture atlas layout
        uv.y = 1 - uv.y;
        if (mod(face,2)==1) {
            uv.x = 1-uv.x;
        }
        if (face >= 4) {
            uv.x = 1-uv.x;
        }
        if (face >= 2 && face <= 3) {
            uv.x = 1-uv.x;
        }

        vec2 faceOffset = cube_face(size, face);
        faceOffset = faceOffset / texture_size;

        vec2 one_face = size / texture_size;
        uv *= one_face;
        vec2 actual_texCoord = floor(texCoord*texture_size)/texture_size;
        vec2 final_uv = actual_texCoord+faceOffset;
        final_uv += uv;

        returnValue = texture(Texture, final_uv);

        if (funny_color.b == 5) {

            float angle = iTime * 100.0; // speed multiplier
            float cosA = cos(angle);
            float sinA = sin(angle);

            // store original x and z
            float origX = dir.x;
            float origZ = dir.z;

            dir.x = origX * cosA - origZ * sinA;
            dir.z = origX * sinA + origZ * cosA;
            // --- Smoke effect improvements ---
            float time = iTime * 200; // slower motion
            vec3 p = dir * 3.0; // base scale
            
            // Layered fractal noise
            float n = 0.0;
            float amp = 0.5;
            float freq = 1.0;
            for (int i = 0; i < 4; i++) {
                n += cnoise_vec4(vec4(p * freq, time * freq)) * amp;
                freq *= 2.0;
                amp *= 0.5;
            }
            n = n * 0.5 + 0.5; // normalize 0..1
            
            // Add turbulence distortion
            vec3 offset = vec3(
                cnoise_vec4(vec4(p * 1.2 + time * 0.4, 0.0)),
                cnoise_vec4(vec4(p * 1.2 + time * 0.4, 1.0)),
                cnoise_vec4(vec4(p * 1.2 + time * 0.4, 2.0))
            );
            float turbulence = length(offset) * 0.5;
            
            // Sample a "shifted" version of the skybox to use as the smoke color source
            vec3 baseColor = texture(Texture, final_uv).rgb;
            vec3 altColor = shifted_color(Texture, final_uv); // shifted version of the skybox
            
            // Blend based on procedural noise
            vec3 smoke = mix(baseColor, altColor, n);
            smoke = mix(smoke, altColor * 0.8 + baseColor * 0.2, turbulence);
            
            // Blend with existing texture
            float intensity = smoothstep(0.3, 0.8, n + turbulence * 0.5);
            //intensity = clamp(intensity-0.4,0,1);
            returnValue.rgb = mix(returnValue.rgb, smoke, intensity * 0.7);

        }

    }
    return returnValue;
}