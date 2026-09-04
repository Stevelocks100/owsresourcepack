// Plasma Globe by nimitz (twitter: @stormoid)
// https://www.shadertoy.com/view/XsjXRm
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
// Contact the author for other licensing options

//looks best with around 25 rays
#define CORE_NUM_RAYS 10.

#define CORE_VOLUMETRIC_STEPS 18

#define CORE_MAX_ITER 16
#define CORE_FAR 10.



mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}

float hash( float n ){return fract(sin(n)*43758.5453);}


float hash11(float p)
{
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash31(vec3 p)
{
    p = fract(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

float core_noise(in float x)
{
    //return hash11(floor(x * CORE_NOISE_PIXELATION));
    return hash11(x);

}

float core_noise(in vec3 p)
{
    // p = floor(p * CORE_NOISE_PIXELATION) / CORE_NOISE_PIXELATION;
    return hash31(p);
}
mat3 m3 = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );


//See: https://www.shadertoy.com/view/XdfXRj
float flow(in vec3 p, in float t, float time)
{
	float z=2.;
	float rz = 0.;
	vec3 bp = p;
	for (float i= 1.;i < 5.;i++ )
	{
		p += time*.1;
		rz+= (sin(core_noise(p+t*0.8)*6.)*0.5+0.5) /z;
		p = mix(bp,p,0.6);
		z *= 2.;
		p *= 2.01;
        p*= m3;
	}
	return rz;	
}

//could be improved
float sins(in float x, float time)
{
 	float rz = 0.;
    float z = 2.;
    for (float i= 0.;i < 3.;i++ )
	{
        rz += abs(fract(x*1.4)-0.5)/z;
        x *= 1.3;
        z *= 1.15;
        x -= time*.65*z;
    }
    return rz;
}

float segm( vec3 p, vec3 a, vec3 b)
{
    vec3 pa = p - a;
	vec3 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1. );	
	return length( pa - ba*h )*.5;
}

vec3 path(in float i, in float d, float time)
{
    vec3 en = vec3(0.,0.,1.);
    float sns2 = sins(d+i*0.5, time)*0.22;
    float sns = sins(d+i*.6, time)*0.21;
    en.xz *= mm2((hash(i*10.569)-.5)*6.2+sns2);
    en.xy *= mm2((hash(i*4.732)-.5)*6.2+sns);
    return en;
}

vec2 map(vec3 p, float i, float time)
{
	float lp = length(p);
    vec3 bg = vec3(0.);   
    vec3 en = path(i,lp, time);
    
    float ins = smoothstep(0.11,.46,lp);
    float outs = .15+smoothstep(.0,.15,abs(lp-1.));
    p *= ins*outs;
    float id = ins*outs;
    
    float rz = segm(p, bg, en)-0.011;
    return vec2(rz,id);
}

float march(in vec3 ro, in vec3 rd, in float startf, in float maxd, in float j, float time)
{
	float precis = 0.001;
    float h=0.5;
    float d = startf;
    for( int i=0; i<CORE_MAX_ITER; i++ )
    {
        if( abs(h)<precis||d>maxd ) break;
        d += h*1.2;
	    float res = map(ro+rd*d, j, time).x;
        h = res;
    }
	return d;
}

//volumetric marching
vec3 vmarch(in vec3 ro, in vec3 rd, in float j, in vec3 orig, float time)
{   
    vec3 p = ro;
    vec2 r = vec2(0.);
    vec3 sum = vec3(0);
    float w = 0.;
    for( int i=0; i<CORE_VOLUMETRIC_STEPS; i++ )
    {
        r = map(p,j, time);
        p += rd*.03;
        float lp = length(p);
        
        vec3 col = sin(vec3(1.05,2.5,1.52)*3.94+r.y)*.85+0.4;
        col.rgb *= smoothstep(.0,.015,-r.x);
        col *= smoothstep(0.04,.2,abs(lp-1.1));
        col *= smoothstep(0.1,.34,lp);
        sum += abs(col)*5. * (1.2-core_noise(lp*2.+j*13.+time*5.)*1.1) / (log(distance(p,orig)-2.)+.75);
    }
    return sum;
}

//returns both collision dists of unit sphere
vec2 iSphere2(in vec3 ro, in vec3 rd)
{
    vec3 oc = ro;
    float b = dot(oc, rd);
    float c = dot(oc,oc) - 1.;
    float h = b*b - c;
    if(h <0.0) return vec2(-1.);
    else return vec2((-b - sqrt(h)), (-b + sqrt(h)));
}

vec4 plasmaGlobe(vec3 worldPosition, vec3 rayOrigin, vec3 direction, float time)
{
    float scale = 3;
    vec3 ro = (rayOrigin - worldPosition) / scale;
    vec3 rd = normalize(direction);

    vec3 bro = ro;
    vec3 brd = rd;

    vec2 bounds = iSphere2(ro, rd);

    if (bounds.x < 0.0 || bounds.y < 0.0)
        return vec4(0.0);

    vec3 col = vec3(0.);

    for (float j = 1.; j < CORE_NUM_RAYS + 1.; j++)
    {
        ro = bro;
        rd = brd;

        mat2 mm = mm2((time * 0.1 + ((j + 1.) * 5.1)) * j * 0.25);

        ro.xy *= mm;
        rd.xy *= mm;
        ro.xz *= mm;
        rd.xz *= mm;

        float rz = march(ro, rd, 0.0, CORE_FAR, j, time);
        if (rz >= CORE_FAR)
            continue;

        vec3 pos = ro + rz * rd;
        col = max(col, vmarch(pos, rd, j, bro, time));
    }

    ro = bro;
    rd = brd;

    vec2 sph = bounds;

    if (sph.x > 0.)
    {
        vec3 pos = ro + rd * sph.x;
        vec3 pos2 = ro + rd * sph.y;

        vec3 rf = reflect(rd, pos);
        vec3 rf2 = reflect(rd, pos2);

        float nz = -log(abs(flow(rf * 1.2, time, time) - .01));
        float nz2 = -log(abs(flow(rf2 * 1.2, -time, time) - .01));

        col += (
            0.1 * nz * nz * vec3(0.12, 0.12, .5) +
            0.05 * nz2 * nz2 * vec3(0.55, 0.2, .55)
        ) * 0.8;
    }

    float intensity = max(max(col.r, col.g), col.b);
    float alpha = clamp(intensity * 2.0, 0.0, 1.0);

    return vec4(col * 1.3, alpha);
}