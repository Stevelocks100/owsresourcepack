// Procedural wood textures v2
// Written by Claus O. Wilke, 2023
// Noise functions were adapted from code written by Inigo Quilez
// The MIT License
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Building on earlier wood texture experiments: https://www.shadertoy.com/view/7tjBW3

// Wood type: choose a number between 1 and 5
#define WOOD_TYPE 4

// ------------------------------------------------------------------
// Replacement hash (no iChannel0 dependency)
// Returns value in [-1, 1]
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 78.233);
    return -1.0 + 2.0 * fract(p.x * p.y);
}

vec2 hash2(vec2 p)
{
    // return numbers between -1 and 1
    return vec2(hash(p), hash(p + vec2(32., 18.)));
}


// value noise
// Inigo Quilez (MIT License)
// https://www.shadertoy.com/view/lsf3WH
float noise1(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
	
	vec2 u = f*f*(3.0 - 2.0*f);

    return mix(mix(hash(i + vec2(0.0, 0.0)), 
                   hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), 
                   hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// gradient noise
// Inigo Quilez (MIT License)
// https://www.shadertoy.com/view/XdXGW8

float noise2_wood(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);

    #if 1
    // quintic smoothstep
    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    #else
    // cubic smoothstep
    vec2 u = f*f*(3.0-2.0*f);
    #endif    

    return mix(mix(dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)), 
                   dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)), 
                   dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}


// simplex noise
// Inigo Quilez (MIT License)
// https://www.shadertoy.com/view/Msf3WH
float noise3_wood(vec2 p)
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

	vec2  i = floor(p + (p.x+p.y)*K1);
    vec2  a = p - i + (i.x+i.y)*K2;
    float m = step(a.y,a.x); 
    vec2  o = vec2(m,1.0-m);
    vec2  b = a - o + K2;
	vec2  c = a - 1.0 + 2.0*K2;
    vec3  h = max(0.5-vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
	vec3  n = h*h*h*h*vec3(dot(a, hash2(i+0.0)), dot(b, hash2(i+o)), dot(c, hash2(i+1.0)));
    return dot(n, vec3(70.0));
}

float fbm3(vec2 p, int octaves)
{
    // rotation matrix for fbm
    mat2 m = 2.*mat2(4./5., 3./5., -3./5., 4./5.);  
     
    float scale = 0.5;
    float f = scale * noise3_wood(p);
    float norm = scale;
    for (int i = 0; i < octaves; i++) {
        p = m * p;
        scale *= .5;
        norm += scale;
        f += scale * noise3_wood(p);
    }
	return 0.5 + 0.5 * f/norm;
}

// deep red
vec3 stripescol2(float f)
{
    return .5 + .4 * sin(1.4*f*f + vec3(2.5) + vec3(0., .6, .9));
}

vec3 discoloration(vec2 uv)
{
    float i = floor(uv.x); // panel index
    vec2 p = .2*vec2(2., 1.)*uv + i * vec2(234., 123.);
    float f = fbm3(p, 2);
    return .5 + .5 * sin(2.3*f + vec3(1.4) + vec3(0., .4, 1.));
}

float finegrain(vec2 uv, float tr)
{
    vec2 p = 3.*vec2(50., 4.)*uv;
    float f = fbm3(0.5*p, 4) - 0.2*tr;
    return 1. - .4*f*(1. - smoothstep(.35, .45, f));
}

float panelgap(vec2 uv)
{
    
    float i = floor(uv.x);
    float s = fract(uv.x) - 0.5;
    
    float gapw = .002;
    
    float w = smoothstep(.5, .5 - gapw, abs(s));
    float f = fbm3(uv + i*vec2(15, 27), 0);
    w = mix(sqrt(f), 1., w);
    
    return w;
}

float treerings2(vec2 p, float a, float b, float c, float d)
{
    float i = floor(p.x);
    float x = fract(p.x);
    
    float n1 = 0.5*noise1(5.*vec2(x, p.y) + vec2(10.*i, 0)) + 0.5;
    float n2 = 0.5*noise2_wood(0.7*vec2(4.*x, p.y) + vec2(0, 5.*i)) + 0.5;
    float f = .5 + 0.5*cos(a*x + b*n1 + c*p.y + d*n2);
    f *= f; 
    return f;
}

vec3 wood4(vec2 p, float lightness, float discolor)
{
    float tr = treerings2(p, 100., 1., 2., 130.);
    vec3 col = stripescol2(0. + 0.7*tr);
    col *= finegrain(p, tr);
    col *= mix(vec3(lightness), discoloration(p), discolor);
    col *= panelgap(p);
    return col;
}

// ------------------------------------------------------------------
// Public entry point
// p should be in object or world space, scaled externally
vec3 wood(vec2 p) {
    // Shadertoy versions expect fairly large coordinates
    // Adjust scale here if needed by the caller
    return wood4(p, 0.3, 0.8);
}
