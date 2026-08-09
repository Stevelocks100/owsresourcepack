float mod289_missing(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289_missing(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm_missing(vec4 x){return mod289_missing(((x * 34.0) + 1.0) * x);}

float noise_missing(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm_missing(b.xyxy);
    vec4 k2 = perm_missing(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm_missing(c);
    vec4 k4 = perm_missing(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float rand_float(float co) {
    return fract(sin(co * 78.233) * 43758.5453);
}

vec3 missing_screen_space(float scale,vec2 shake,vec2 speed, vec2 ScreenCoord) {
    // Convert to grid coordinates
    vec2 fragCoord = ScreenCoord + GameTime*128000*speed;
    fragCoord = fragCoord + (vec2(rand_float(GameTime*1200),rand_float(GameTime*1200 + 20.0))*4-2)*shake;
    vec2 grid = floor(fragCoord * scale / 100.0);

    // Checkerboard pattern: sum X+Y, even=magenta, odd=black
    float checker = mod(grid.x + grid.y, 2.0);

    if (checker < 0.5) {
        return vec3(1.0, 0.0, 1.0); // Magenta
    } else {
        return vec3(0.0); // Black
    }
}

vec3 missing_object(vec2 ScreenCoord) {

        return mix(
            missing_screen_space(1,vec2(5),vec2(4), ScreenCoord), 
            missing_screen_space(1.2,vec2(13,4),vec2(2,1), ScreenCoord),
            clamp(sin(GameTime*2400)/2+0.3,0,0.7)
        );
}

vec3 missing_object_scale(vec2 ScreenCoord,float scale) {

        return mix(
            missing_screen_space(1 * scale,vec2(5),vec2(4), ScreenCoord), 
            missing_screen_space(1.2 * scale,vec2(13,4),vec2(2,1), ScreenCoord),
            clamp(sin(GameTime*2400)/2+0.3,0,0.7)
        );
}

vec3 missing(vec3 ro, vec3 rd, vec2 ScreenCoord) {
    float voxelSize = 0.25;

    vec3 bg = missing_object(ScreenCoord);
    //vec3 bg = vec3(1.0, 0.0, 0.0); // pink background
    //vec3 col = mix(bg,vec3(0.5),0.2);
    vec3 col = vec3(0);

    float t = 0.0;
    float max_t = 40;
    vec2 shake = (vec2(rand_float(GameTime*1200),rand_float(GameTime*1200 + 20.0))-0.5) / 8 * clamp(sin(GameTime*2400)/2+0.3,0,0.7);
    for (int i = 0; i < 80; i++) {
        vec3 p = ro + rd * t;
        float t_mix = smoothstep(max_t - max_t/2,max_t,t);
        p += shake.xyx + vec3(GameTime*600,GameTime*600,0) - vec3(0,(t_mix*t_mix+1)*GameTime*2400,0);
        voxelSize = mix(0.5,5,
        t_mix
        );

        // voxel coordinates
        vec3 vp = p / voxelSize;
        vec3 cell = floor(vp);

        // jitter inside voxel (makes it less grid-like)
        vec3 f = fract(vp);

        // sample noise at voxel center
        vec3 noiseInput = vec3(cell * 0.35);
        float n = noise_missing(noiseInput);

        // turn noise into "solid voxel"
        float density = n * 0.5 + 0.5;



        // threshold
        if (density > 0.93) {
            //bg = missing_object_scale(ScreenCoord,t/max_t+1);

            col = mix(
                vec3(0),
                bg,
                smoothstep(max_t - max_t/4,max_t,t)
                );
            
            
            
            if (density > 0.97) col = mix(
                vec3(1,0,1),
                bg,
                smoothstep(max_t - max_t/4,max_t,t)
                );
                

            if (t < 20) col = mix(
                bg,
                vec3(0),
                0.2
                );
            
            break;
        }

        // adaptive stepping (important for speed)
        float stepSize = mix(0.15, 0.6, density);
        t += stepSize;

        if (t > max_t) break;
    }

    return col;
}

bool isSkin(sampler2D tex) {
    return round(texelFetch(tex,ivec2(0,6),0).rgb*255) == vec3(200,137,146) && textureSize(tex,0) == vec2(64);
}