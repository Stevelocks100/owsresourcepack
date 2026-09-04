// Plasma Globe by nimitz (twitter: @stormoid)
// https://www.shadertoy.com/view/XsjXRm
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
// Contact the author for other licensing options

//looks best with around 25 rays
#define NUM_RAYS 13.

#define VOLUMETRIC_STEPS 19

#define MAX_ITER 35
#define FAR 6.

#define core_time GameTime*1.1*1200


mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}

float core_hash(vec3 p)
{
    p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float core_hash(float n)
{
    return fract(sin(n) * 43758.5453);
}

float core_noise(in float p)
{
    return core_hash(p);
}

float core_noise(in vec3 p)
{
    vec3 ip = floor(p);
    vec3 fp = fract(p);

    fp = fp * fp * (3.0 - 2.0 * fp);

    float n000 = core_hash(ip + vec3(0.0, 0.0, 0.0));
    float n100 = core_hash(ip + vec3(1.0, 0.0, 0.0));
    float n010 = core_hash(ip + vec3(0.0, 1.0, 0.0));
    float n110 = core_hash(ip + vec3(1.0, 1.0, 0.0));

    float n001 = core_hash(ip + vec3(0.0, 0.0, 1.0));
    float n101 = core_hash(ip + vec3(1.0, 0.0, 1.0));
    float n011 = core_hash(ip + vec3(0.0, 1.0, 1.0));
    float n111 = core_hash(ip + vec3(1.0, 1.0, 1.0));

    float x00 = mix(n000, n100, fp.x);
    float x10 = mix(n010, n110, fp.x);
    float x01 = mix(n001, n101, fp.x);
    float x11 = mix(n011, n111, fp.x);

    float y0 = mix(x00, x10, fp.y);
    float y1 = mix(x01, x11, fp.y);

    return mix(y0, y1, fp.z);
}

mat3 m3 = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );


//See: https://www.shadertoy.com/view/XdfXRj
float flow(in vec3 p, in float t)
{
	float z=2.;
	float rz = 0.;
	vec3 bp = p;
	for (float i= 1.;i < 5.;i++ )
	{
		p += core_time*.1;
		rz+= (sin(core_noise(p+t*0.8)*6.)*0.5+0.5) /z;
		p = mix(bp,p,0.6);
		z *= 2.;
		p *= 2.01;
        p*= m3;
	}
	return rz;	
}

//could be improved
float sins(in float x)
{
 	float rz = 0.;
    float z = 2.;
    for (float i= 0.;i < 3.;i++ )
	{
        rz += abs(fract(x*1.4)-0.5)/z;
        x *= 1.3;
        z *= 1.15;
        x -= core_time*.65*z;
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

vec3 path(in float i, in float d)
{
    vec3 en = vec3(0.,0.,1.);
    float sns2 = sins(d+i*0.5)*0.22;
    float sns = sins(d+i*.6)*0.21;
    en.xz *= mm2((core_hash(i*10.569)-.5)*6.2+sns2);
    en.xy *= mm2((core_hash(i*4.732)-.5)*6.2+sns);
    return en;
}

vec2 map(vec3 p, float i)
{
	float lp = length(p);
    vec3 bg = vec3(0.);   
    vec3 en = path(i,lp);
    
    float ins = smoothstep(0.11,.46,lp);
    float outs = .15+smoothstep(.0,.15,abs(lp-1.));
    p *= ins*outs;
    float id = ins*outs;
    
    float rz = segm(p, bg, en)-0.011;
    return vec2(rz,id);
}

float march(in vec3 ro, in vec3 rd, in float startf, in float maxd, in float j)
{
	float precis = 0.001;
    float h=0.5;
    float d = startf;
    for( int i=0; i<MAX_ITER; i++ )
    {
        if( abs(h)<precis||d>maxd ) break;
        d += h*1.2;
	    float res = map(ro+rd*d, j).x;
        h = res;
    }
	return d;
}

//volumetric marching
vec3 vmarch(in vec3 ro, in vec3 rd, in float j, in vec3 orig)
{   
    vec3 p = ro;
    vec2 r = vec2(0.);
    vec3 sum = vec3(0);
    float w = 0.;
    for( int i=0; i<VOLUMETRIC_STEPS; i++ )
    {
        r = map(p,j);
        p += rd*.03;
        float lp = length(p);
        
        vec3 col = sin(vec3(1.05,2.5,1.52)*3.94+r.y)*.85+0.4;
        col.rgb *= smoothstep(.0,.015,-r.x);
        col *= smoothstep(0.04,.2,abs(lp-1.1));
        col *= smoothstep(0.1,.34,lp);
        sum += abs(col)*5. * (1.2-core_noise(lp*2.+j*13.+core_time*5.)*1.1) / (log(distance(p,orig)-2.)+.75);
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

vec4 plasmaGlobe(vec3 RayOrigin, vec3 RayDirection, vec3 EffectPosition)
{

    float scale = 4;
    vec3 ro = RayOrigin - EffectPosition;
    ro /= scale;
    vec3 rd = normalize(RayDirection);

    vec3 bro = ro;
    vec3 brd = rd;



    // for (float j = 1.;j<NUM_RAYS+1.;j++)
    // {
    //     ro = bro;
    //     rd = brd;
    //     mat2 mm = mm2((core_time*0.1+((j+1.)*5.1))*j*0.25);
    //     ro.xy *= mm;rd.xy *= mm;
    //     ro.xz *= mm;rd.xz *= mm;
    //     float rz = march(ro,rd,2.5,FAR,j);
	// 	if ( rz >= FAR)continue;
    // 	vec3 pos = ro+rz*rd;
    // 	col = max(col,vmarch(pos,rd,j, bro));
    // }
    
    ro = bro;
    rd = brd;
    vec3 col = vec3(0.0);

    vec2 sph = iSphere2(ro, rd);

    if (sph.y > 0. || sph.x > 0.)
    {

        vec3 pos = ro + rd * sph.x;
        vec3 pos2 = ro + rd * sph.y;

        vec3 normal = normalize(pos);
        float fresnel = 1.0 - max(dot(-rd, normal), 0.0);
        fresnel = pow(fresnel, 3.0);

        col += fresnel * vec3(0.25, 0.35, 1.0) * 2.0;

        vec3 rf = reflect(rd, pos);
        vec3 rf2 = reflect(rd, pos2);

        float nz = (-log(abs(flow(rf * 1.2, core_time) - .1)));
        float nz2 = (-log(abs(flow(rf2 * 1.2, -core_time) - .1)));

        // col += (
        //     0.1 * nz * nz * vec3(0.12, 0.12, .5) +
        //     0.05 * nz2 * nz2 * vec3(.55, .2, .55)
        // ) * 2.0;
        col += (
            0.1 * nz * nz * vec3(0.3, 0.3, 1.0) +
            0.05 * nz2 * nz2 * vec3(1.0, 0.3, 1.0)
        ) * 2.0;
    }

    float intensity = max(max(col.r, col.g), col.b);

    float alpha = 1.0 - exp(-intensity * 3.0);

    return vec4(col * 2.0, alpha);
        

}