// Star map shader...procedural space background

#define BASESKYBOXSUN

const float base_deg = 3.1415927 / 180.0;

// See derivation of noise functions by Morgan McGuire at https://www.shadertoy.com/view/4dS3Wd
const int NUM_OCTAVES = 4;
float hash_base(float n) { return fract(sin(n) * 1e4); }
float hash_base(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }
// 1 octave value noise
float noise_base(float x) { float i = floor(x); float f = fract(x); float u = f * f * (3.0 - 2.0 * f); return mix(hash_base(i), hash_base(i + 1.0), u); }
float noise_base(vec2 x) { vec2 i = floor(x); vec2 f = fract(x);	float a = hash_base(i); float b = hash_base(i + vec2(1.0, 0.0)); float c = hash_base(i + vec2(0.0, 1.0)); float d = hash_base(i + vec2(1.0, 1.0)); vec2 u = f * f * (3.0 - 2.0 * f); return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y; }
float noise_base(vec3 x) { const vec3 step = vec3(110, 241, 171); vec3 i = floor(x); vec3 f = fract(x); float n = dot(i, step); vec3 u = f * f * (3.0 - 2.0 * f); return mix(mix(mix( hash_base(n + dot(step, vec3(0, 0, 0))), hash_base(n + dot(step, vec3(1, 0, 0))), u.x), mix( hash_base(n + dot(step, vec3(0, 1, 0))), hash_base(n + dot(step, vec3(1, 1, 0))), u.x), u.y), mix(mix( hash_base(n + dot(step, vec3(0, 0, 1))), hash_base(n + dot(step, vec3(1, 0, 1))), u.x), mix( hash_base(n + dot(step, vec3(0, 1, 1))), hash_base(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z); }
// Multi-octave value noise
float NOISE_base(float x) { float v = 0.0; float a = 0.5; float shift = float(100); for (int i = 0; i < NUM_OCTAVES; ++i) { v += a * noise_base(x); x = x * 2.0 + shift; a *= 0.5; } return v; }
float NOISE_base(vec2 x) { float v = 0.0; float a = 0.5; vec2 shift = vec2(100); mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50)); for (int i = 0; i < NUM_OCTAVES; ++i) { v += a * noise_base(x); x = rot * x * 2.0 + shift; a *= 0.5; } return v; }
// Fast hash2 from https://www.shadertoy.com/view/lsfGWH
float hash2_base(vec2 co) { return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453); }
float maxComponent(vec2 v) { return max(v.x, v.y); }
float maxComponent(vec3 v) { return max(max(v.x, v.y), v.z); }
float minComponent(vec2 v) { return min(v.x, v.y); }
mat3 rotation(float yaw, float pitch) { return mat3(cos(yaw), 0, -sin(yaw), 0, 1, 0, sin(yaw), 0, cos(yaw)) * mat3(1, 0, 0, 0, cos(pitch), sin(pitch), 0, -sin(pitch), cos(pitch)); }
float square(float x) { return x * x; }

///////////////////////////////////////////////////////////////////////

// Only globals needed for the actual spheremap

// starplane was derived from https://www.shadertoy.com/view/lsfGWH
float starplane(vec3 dir, float iTime, vec2 iResolution) { 
    float screenscale = 1.0 / iResolution.x;

    // Project to a cube-map plane and scale with the resolution of the display
    vec2 basePos = dir.xy * (0.5 / screenscale) / max(1e-3, abs(dir.z));
         
	const float largeStarSizePixels = 20.0;
    
    // Probability that a pixel is NOT on a large star. Must change with largeStarSizePixels
	const float prob = 0.97;
    	
	float color = 0.0;
	vec2 pos = floor(basePos / largeStarSizePixels);
	float starValue = hash2_base(pos);
    
    // Big stars
	if (starValue > prob) {

        // Sphere blobs
		vec2 delta = basePos - largeStarSizePixels * (pos + vec2(0.5));
		color = max(1.0 - length(delta) / (0.5 * largeStarSizePixels), 0.0);
		
        // Star shapes
        color *= 1.0 / max(1e-3, abs(delta.x) * abs(delta.y));
        
        // Avoid triplanar seams where star distort and clump
        color *= pow(abs(dir.z), 12.0);
    } 

    // Small stars

    // Stabilize stars under motion by locking to a grid
    basePos = floor(basePos);

    if (hash2_base(basePos.xy * screenscale) > 0.997) {
        float r = hash2_base(basePos.xy * 0.5);
        color += r * (0.3 * sin(iTime * (r * 5.0) + r) + 0.7) * 1.5;
    }
	
    // Weight by the z-plane
    return color * abs(dir.z);
}


float starbox(vec3 dir, float iTime, vec2 iResolution) {
	return starplane(dir.xyz, iTime, iResolution) + starplane(dir.yzx, iTime, iResolution) + starplane(dir.zxy, iTime, iResolution);
}    


float starfield(vec3 dir, float iTime, vec2 iResolution) {
    return starbox(dir, iTime, iResolution) + starbox(rotation(45.0 * base_deg, 45.0 * base_deg) * dir, iTime, iResolution);
}


vec3 nebula(vec3 dir, float iTime) {
    float purple = abs(dir.x);
    float yellow = noise_base(dir.y);
    vec3 streakyHue = vec3(purple * 0.2, yellow * 0.5, purple + yellow);
    vec3 puffyHue = vec3(0.1, 0.3, 1.0);

    float warpTime = iTime * 0.15;

    vec2 warp = vec2(
        NOISE_base(dir.yz * 2.0 + warpTime),
        NOISE_base(dir.xz * 2.0 - warpTime)
    ) - 0.5;

    vec2 streakCoord =
        dir.yz * square(dir.x) * 13.0 +
        dir.xy * square(dir.z) * 7.0 +
        warp * 2.0 +
        vec2(150.0, 2.0);

    float streaky = min(
        1.0,
        8.0 * pow(NOISE_base(streakCoord), 10.0)
    );
    float puffy = square(NOISE_base(dir.xz * 4.0 + vec2(30, 10)) * dir.y);

    return clamp(puffyHue * puffy * (1.0 - streaky) + streaky * streakyHue, 0.0, 1.0);
}


vec3 sun(vec3 d, float iTime, bool doSun) {

    if (!doSun) return vec3(0);
    #ifdef BASESKYBOXSUN
        float angle = atan(d.x, d.y);    
        float falloff = pow(max(d.z, 0.0), 10.0);
        vec3 core = vec3(2.8, 1.5 + 0.5 * noise_base(iTime * 0.25 + d.xy * 5.0), 1.5) * falloff; 
        float corona = NOISE_base(vec2(d.z * 250.0 + iTime, iTime * 0.2 + angle * 50.0)) * smoothstep(0.95, 0.92, d.z) * falloff * square(d.z);
        
        return core * (1.0 - corona);
    #else
        return vec3(0);
    #endif
}





vec3 sphereColor(vec3 dir, float iTime, vec2 iResolution, bool doSun) {
    vec3 n = nebula(dir, iTime);

    return sun(dir, iTime, doSun) + 
        (vec3(starfield(dir, iTime, iResolution)) * (1.0 - maxComponent(n)) + n);
    

}

vec3 base_skybox( vec3 dir, float iTime, vec2 iResolution) {
    //return dir/2 + 0.5;
    return sqrt(sphereColor(vec3(dir.x,dir.y,-dir.z), iTime, iResolution, true));
}
vec3 base_skybox_nosun( vec3 dir, float iTime, vec2 iResolution) {
    //return dir/2 + 0.5;
    return sqrt(sphereColor(vec3(dir.x,dir.y,-dir.z), iTime, iResolution, false));
}




struct LightSource {
    vec3 position;
    vec3 color;
    float strength;
};

LightSource skybox_lights[] = LightSource[](
    LightSource(
        vec3(0.0, 0.0, 50.0),
        normalize(vec3(1.5, 1.3, 1.1)),
        2.0
    ),
    LightSource(
        vec3(-50,0,0),
        vec3(74, 2, 156)/255,
        0.7
    ),
    LightSource(
        vec3(50,0,0),
        vec3(74, 2, 156)/255,
        0.7
    ),
    LightSource(
        vec3(0,50,0),
        vec3(41, 97, 182)/255,
        1.3
    )
);

const int skybox_lightcount = 4;

vec3 applyLights(
    vec3 playerColor,
    vec3 normal
) {
    vec3 result = mix(playerColor,playerColor * vec3(41, 97, 182)/255, 0.8);
    result = playerColor;
    

    for (int i = 0; i < skybox_lightcount; i++) {
        #ifndef BASESKYBOXSUN
            if (i == 0) continue;
        #endif

        float distance = length(skybox_lights[i].position);
        vec3 lightDir = skybox_lights[i].position / max(distance, 0.0001);

        // Lambert lighting
        float facing = max(dot(vec3(normal.x,normal.y,-normal.z), lightDir), 0.0);



        // Add colored light
        result += playerColor *
                  skybox_lights[i].color *
                  skybox_lights[i].strength *
                  facing;
    }

    return result;
}

//vec3 base_center = vec3(836.5, 125.0, -444.5);
const vec3 base_center = vec3(24.5, 196.0, -790.5);


float apply_base_skybox(
    vec3 position
) {
    float radius = length(position.xz - base_center.xz);
    float strength = smoothstep(12.5,12,radius);
    strength *= smoothstep(base_center.y-1,base_center.y,position.y) * smoothstep(base_center.y+8.5,base_center.y+8,position.y);
    return strength;
    
}

vec3 base_lightmap() {
    #ifndef BASESKYBOXSUN
        return vec3(41, 97, 182)/255 * 0.4;
    #else
        return mix(vec3(41, 97, 182)/255 * 0.4,vec3(1)*0.4,0.6);
    #endif
}