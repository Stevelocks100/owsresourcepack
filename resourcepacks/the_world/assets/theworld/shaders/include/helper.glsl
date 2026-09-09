bool matchingColor(vec3 color) {
    return (distance(color,vec3(156,53,97)) < 2);
}

bool isControlColor() {
    vec3 theworld_color = round(texelFetch(MainSampler,ivec2(2,2),0).rgb * 255);

    if (matchingColor(theworld_color)) {
        return true;
    }
    return false;
}

bool shouldReplace(ivec2 fragCoord) {
    vec3 current_color = round(texelFetch(MainSampler,fragCoord,0).rgb * 255);
    vec3 adjacent_color = round(texelFetch(MainSampler,fragCoord - ivec2(1,0),0).rgb * 255);
    if (matchingColor(current_color) || matchingColor(adjacent_color)) {
        return true;
    }
    return false;
}

bool visible() {
    vec3 theworld_color = round(texelFetch(MainSampler,ivec2(2,2),0).rgb * 255);
    return (theworld_color == vec3(156,53,97));
}

bool is_active() {
    float vertexColor = texelFetch(MainSampler,ivec2(3,2),0).r;

    return (vertexColor == 0);
}

vec3 encode_time(float time) {
    float t = floor(time*2);

    float r = mod(t, 256.0);
    t = floor(t / 256.0);

    float g = mod(t, 256.0);
    t = floor(t / 256.0);

    float b = mod(t, 256.0);

    return vec3(r, g, b) / 255;
}

float decode_time(vec3 rgb) {
    vec3 v = rgb * 255;
    return (v.r + v.g * 256 + v.b * 65536) / 2;
}


float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float valueNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Smoothstep curve (same as texture filtering vibe)
    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i + vec2(0.0, 0.0));
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}



float fractalNoise(vec2 p) {
    float q = 1.0;
    float t = 0.0;

    for (int n = 0; n < 6; n++) {
        t += (valueNoise(p * q) - 0.5) / (q * 2.0);
        q *= 2.0;
    }

    return t;
}

vec4 fractalField(vec2 fragCoord) {
    vec2 r = ScreenSize;
    const float PI = 3.141592653589793;


    vec2 p = (fragCoord + fragCoord - r) / sqrt(r.x * r.y);

    vec4 c = vec4(0.0);

    for (float i = 0.0; i < 46.0; i++) {
        float phase = i * PI * 2.0 * 0.618;

        vec2 dir = cos(phase + vec2(0.0, 0.5) * PI);
        vec2 ofs = sin(phase + vec2(0.0, 0.5) * PI);

        float time = GameTime * 1200.0;

        float n = fractalNoise(p * 1.5);
        n += 0.15 * sin(time + phase);


        c += vec4(n);
        p += ofs * c.x * 0.75;
    }

    c *= c;
    return c;
}



float sdBox(vec2 p, vec2 halfSize) {
    vec2 d = abs(p) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdBoxOutline(vec2 p, vec2 halfSize, float width) {
    float d = sdBox(p, halfSize);
    return abs(d) - width * 0.5;
}

vec2 clampToNDCEdge(vec2 ndc, float edge) {
    // Avoid division by zero
    vec2 a = abs(ndc);

    // Find scale needed to hit the square boundary
    float scale = 1.0 / max(a.x, a.y);

    return -ndc * scale * edge;
}

vec2 ndcToUV(vec2 ndc) {
    return ndc * 0.5 + 0.5;
}

vec2 uvToNDC(vec2 uv) {
    return uv * 2.0 - 1.0;
}

vec2 pullUV(vec2 uv, vec2 center, float strength) {
    vec2 d = center - uv;
    float r = length(d);

    // falloff curve (tweakable)
    float f = exp(-r * 6.0);

    return uv + d * f * strength;
}

float threshold(float x,float y) {
    if (x < y) {
        return 0;
    }
    return 1;
}

vec4 weighted_merge(vec4 a, vec4 b) {
    float wa = a.a;
    float wb = b.a;

    float w = wa + wb;
    if (w <= 0.0) return vec4(0.0);

    vec3 rgb = (a.rgb * wa + b.rgb * wb) / w;

    return vec4(rgb, clamp(w, 0.0, 1.0));
}

vec3 hueShift(vec3 c, float h) {
    const mat3 RGBtoYIQ = mat3(
        0.299,  0.587,  0.114,
        0.596, -0.275, -0.321,
        0.212, -0.523,  0.311
    );

    const mat3 YIQtoRGB = mat3(
        1.0,  0.956,  0.621,
        1.0, -0.272, -0.647,
        1.0, -1.106,  1.703
    );

    vec3 yiq = RGBtoYIQ * c;

    float cosh = cos(h);
    float sinh = sin(h);

    mat3 rot = mat3(
        1.0,  0.0,   0.0,
        0.0,  cosh, -sinh,
        0.0,  sinh,  cosh
    );

    return clamp(YIQtoRGB * (rot * yiq), 0.0, 1.0);
}

mat4 saturationMatrix( float saturation )
{
    vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
    
    float oneMinusSat = 1.0 - saturation;
    
    vec3 red = vec3( luminance.x * oneMinusSat );
    red+= vec3( saturation, 0, 0 );
    
    vec3 green = vec3( luminance.y * oneMinusSat );
    green += vec3( 0, saturation, 0 );
    
    vec3 blue = vec3( luminance.z * oneMinusSat );
    blue += vec3( 0, 0, saturation );
    
    return mat4( red,     0,
                 green,   0,
                 blue,    0,
                 0, 0, 0, 1 );
}

vec3 adjustSaturation(vec3 c, float sat) {
    return (vec4(c,1) * saturationMatrix(sat)).rgb;
}

vec3 sepia(vec3 c, float amount) {
    vec3 s = vec3(
        dot(c, vec3(0.393, 0.769, 0.189)),
        dot(c, vec3(0.349, 0.686, 0.168)),
        dot(c, vec3(0.272, 0.534, 0.131))
    );
    return mix(c, clamp(s, 0.0, 1.0), amount);
}

float ringFade(
    vec2 p,        // position relative to center
    float radius,  // ring center radius
    float thickness,
    float feather  // edge softness
) {
    float d = abs(length(p) - radius);
    return 1.0 - smoothstep(thickness * 0.5, thickness * 0.5 + feather, d);
}

float sdEllipse(vec2 p, vec2 radius) {
    // scale space so ellipse becomes a unit circle
    vec2 q = p / radius;
    return length(q) - 1.0;
}

float ellipseMask(
    vec2 p,
    vec2 radius,
    float feather
) {
    float d = sdEllipse(p, radius);
    return smoothstep(feather, 0.0, d);
}