#define PI 3.1415926535

#define V3 vec3
#define V2 vec2
#define S smoothstep
#define N normalize
#define M mix

// noise
V3 h33(V3 p) {
    p = V3(
        dot(p, V3(127.1, 311.7,  74.7)),
        dot(p, V3(269.5, 183.3, 246.1)),
        dot(p, V3(113.5, 271.9, 124.6))
    );
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float h12(V2 p) {
    V3 q = fract(V3(p.xyx) * 0.1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

float perlin(V3 p) {
    V3 pi = floor(p), pf = p - pi,
    w = pf*pf*(3. - 2.*pf);
    V2 e = V2(1,0);

    return M(
        M(
            M(dot(h33(pi), pf),
                dot(h33(pi + e.xyy), pf - e.xyy), w.x),
            M(dot(h33(pi + e.yxy), pf - e.yxy),
                dot(h33(pi + e.xxy), pf - e.xxy), w.x),
            w.y
        ),
        M(
            M(dot(h33(pi + e.yyx), pf - e.yyx),
                dot(h33(pi + e.xyx), pf - e.xyx), w.x),
            M(dot(h33(pi + e.yxx), pf - e.yxx),
                dot(h33(pi + e.xxx), pf - e.xxx), w.x),
            w.y
        ),
        w.z
    );
}



float fbm(V3 p) {
    float v = 0., a = .5;
    for (int i = 0; i < 2; ++i) {
        v += a * perlin(p);
        p *= 2.;
        a *= .5;
    }
    return v*.5 + .5;
}

// uv transform
float Ori(vec2 uv, float T)
{
    // Reduce vertical detail density and animation cost
    return fbm(V3(uv * V2(1.25, 3.5) - V2(0., T * 5.), T * 0.6));
}

// Seam angle (-0.9,-1.0) & (0.9, 1.0)
float Se(vec2 uv, float T)
{
    return M(Ori(uv, T), Ori( uv + V2(-sign(uv.x)*2., 0.) , T), S(.9, 1., abs(uv.x))*.5);
}

// Height
float Hei(vec2 uv, float T) {
    float rawCore = Se(uv, T);
    // Early shaping avoids expensive work on weak regions
    rawCore = clamp(rawCore, 0.0, 1.0);
    
    float h = S(.28, .88, rawCore);

    // Sharpen ripple transitions
    h = pow(h, 1.6);

    // Stronger bright ridges
    h += 2.2 * S(.48, .62, rawCore);

    // Extra micro ripple contrast
    h += rawCore * 0.18;
    
    return h;
}

// Calculate Normal
vec3 Nor(vec2 uv, float T)
{
    // Larger offset = cheaper-looking but far fewer high frequency details
    V2 e = V2(0.006, 0.);

    float hC = Hei(uv, T);
    float hR = Hei(uv + e.xy, T);
    float hU = Hei(uv + e.yx, T);

    V2 g = V2(hR - hC, hU - hC);

    return N(V3(-g * 24., 1.));
}

vec4 BladeEffect(vec2 ndc, float time)
{
    // NDC coordinates expected in range -1 to 1
    V2 u = ndc;
    V2 uv = vec2(atan(u.y, u.x) / PI, length(u) * 2. - 1.);

    // Fiery palette
    V3 lCol = vec3(1.3, 0.35, 0.08),
       v = V3(0., 0., 1.),
       dCol = V3(0.18, 0.02, 0.005),
       sCol = V3(1.0, 0.25, 0.03),
       n = Nor(uv, time);

    float h = Hei(uv, time);
    V3 bCol = mix(dCol, sCol, h);

    // Directional Light
    V3 ld1 = N(vec3(1.)), ld2 = N(vec3(-1., 1., 1.));
    float ndld1 = max(dot(n, ld1), 0.);
    float ndld2 = max(dot(n, ld2), 0.);

    V3 hd1 = N(ld1 + v), hd2 = N(ld2 + v);
    float specD = (
        pow(max(dot(n, hd1), 0.), 24.) +
        pow(max(dot(n, hd2), 0.), 24.)
    ) * 0.8;

    // Fresnel
    float nv = 1. - max(dot(n, v), 0.);
    float f = .08 + .92 * nv * nv * nv;
    V3 env = V3(.12, .02, .01) * (1. - f) + f * V3(1.0, .30, .10);

    // Color
    vec3 col = env + (ndld1 + ndld2) * bCol + specD * lCol;
    col += S(.12, .82, length(n.xy)) * .22 * V3(1.0, .55, .12);

    float vignette = max(0.0, 1.0 - dot(u, u) * 0.85);
    float alpha = clamp(h * vignette, 0.0, 1.0);
    alpha = round(alpha);

    return vec4(col * alpha, alpha*alpha);
}