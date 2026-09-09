
float snoise_sauron(vec3 uv, float res)
{
	const vec3 s = vec3(1e0, 1e2, 1e3);
	
	uv *= res;
	
	vec3 uv0 = floor(mod(uv, res))*s;
	vec3 uv1 = floor(mod(uv+vec3(1.), res))*s;
	
	vec3 f = fract(uv); f = f*f*(3.0-2.0*f);

	vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,
		      	  uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);

	vec4 r = fract(sin(v*1e-1)*1e3);
	float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	r = fract(sin((v + uv1.z - uv0.z)*1e-1)*1e3);
	float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	return mix(r0, r1, f.z)*2.-1.;
}

vec2 eyeDistort(vec2 uv) {
    // Remap UV from [0,1] to [-1,1]
    vec2 centeredUV = uv * 2.0 - 1.0;

    // Get distance from center
    float x = centeredUV.x;
    float y = centeredUV.y;

    // Eye squash shape: horizontal ellipse with pinched sides
    float factor = sqrt(1.0 - x * x); // Squeeze more near left/right

    y *= factor;

    // Output: back to [0,1]
    return vec2(x, y) * 0.5 + 0.5;
}

bool circle_sauron( vec2 center, float radius, vec2 pos ) {

    if (distance(center, pos) < radius) {
        return true;
    }
    return false;
}

bool pupil(vec2 uv, float size)
{
    return circle_sauron(vec2(0.7, 0.5), size, uv)
        && circle_sauron(vec2(0.3, 0.5), size, uv);
}

vec4 sauron( vec2 uv ) 
{

    vec2 p = (uv - 0.5) * vec2(1.2, 1.8);
    float iTime = GameTime * 1700;
	
	float color = 3.0 - (3.*length(2.*p));
	
	vec3 coord = vec3(atan(p.x,p.y)/6.2832+.5, length(p)*.4, .5);
	
	for(int i = 1; i <= 7; i++)
	{
		float power = pow(2.0, float(i));
		color += (1.5 / power) 
                * snoise_sauron(coord 
                + vec3(0.,-iTime*.05, iTime*.01), power*16.);
	}

    float alpha = color;

    vec2 pupil_movement = uv;
    pupil_movement += 0.02 * vec2(cos(iTime * 0.5), sin(iTime * 0.7));
    //pupil_movement += vec2(cos(iTime),sin(iTime));
    if (pupil(pupil_movement, 0.23)) {
        color *= 0.1;
        alpha = 1.0;
    }


    vec4 final_color = vec4( 
                color, 
                pow(max(color,0.),2.)*0.4, 
                pow(max(color,0.),3.)*0.15,
                alpha
                );


	return final_color;

    
}