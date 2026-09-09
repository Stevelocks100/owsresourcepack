#version 150

uniform sampler2D InSampler;
uniform sampler2D MainSampler;
uniform sampler2D ITimeSampler;


#moj_import <minecraft:globals.glsl>
#moj_import <theworld:helper.glsl>

layout(std140) uniform BlitConfig {
    vec4 ColorModulate;
};

in vec2 texCoord;

out vec4 fragColor;


vec4 normal_code() {
    return texture(InSampler, texCoord) * ColorModulate;
}

vec3 discolored(vec3 current_color) {
    vec3 new_color = hueShift(adjustSaturation(current_color,0.8),GameTime*3400);

    
    return mix(current_color,new_color,0.6);
}

vec3 stoppedTimeColor(vec3 current_color) {
    //current_color = adjustSaturation(current_color,0.5);
    current_color = clamp(current_color-0.15,vec3(0),vec3(1));
    current_color = sepia(current_color,0.7);
    return current_color;
}

vec4 chromaticAberration(
    sampler2D tex,
    vec2 uv,
    vec2 center,
    float strength
) {
    vec2 dir = uv - center;

    vec2 rUV = uv + dir * strength;
    vec2 bUV = uv - dir * strength;

    float r = texture(tex, rUV).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, bUV).b;

    return vec4(r, g, b, texture(tex, uv).a);
}

vec4 special_code() {
    vec4 returnValue = vec4(0.0);
    if (shouldReplace(ivec2(gl_FragCoord.xy))) {
        returnValue = texelFetch(MainSampler,ivec2(gl_FragCoord.xy)+ivec2(0,1),0);
    }
    vec2 uv = gl_FragCoord.xy / ScreenSize;
    vec2 ndc = (uv * 2) - 1;
    float range = 1.4;
    vec2 theworld_pos = texelFetch(MainSampler,ivec2(3,2),0).gb;
    theworld_pos = (theworld_pos * 2.0 - 1.0) * range;
    if (!visible()) {
        theworld_pos = clampToNDCEdge(theworld_pos, 1.2);
    }
    float start_time = decode_time(texelFetch(ITimeSampler,ivec2(1,0),0).rgb);
    float current_time = GameTime * 24000;
    float time = mod(current_time - start_time + 24000.0, 24000.0) / 20;


    float warp_strength = min((time)*(time - 2.2),0);
    float time_effect = smoothstep(0,-1.21,warp_strength);
    time_effect = 1 - pow(1 - time_effect, 2);
    warp_strength = 1 - pow(1 - time_effect, 2);
    vec2 current_coords = pullUV(
        ndcToUV(ndc),
        ndcToUV(theworld_pos),
        -warp_strength*3
    );
    current_coords = clamp(current_coords,vec2(0.0001),vec2(0.99999));
    if (is_active()) {
        //returnValue = texture(MainSampler,current_coords);
        returnValue = chromaticAberration(MainSampler,current_coords,vec2(0.5),smoothstep(0,2,time)*0.02*(abs(time_effect)*1.2+1));
        vec2 ellipseRadius = vec2(1.0, 0.7) * ((1.0 - time_effect) * 4.5 );
        float d = sdEllipse(ndc - theworld_pos, ellipseRadius);
        if (d > 0.05) {
            returnValue.rgb = discolored(returnValue.rgb);
        } else if (d > -0.05) {
            float color = fractalField(gl_FragCoord.xy*4).a;
            color = threshold(smoothstep(0,1,color),0.4);
            returnValue.rgb += vec3(color);
        }
        returnValue.rgb += vec3(ringFade(ndc - theworld_pos,(time-0.5)*4,0.01,0.7))*0.25;
        returnValue.rgb += vec3(ringFade(ndc - theworld_pos,(2.2 - time)*5,0.01,0.7))*0.25;

        if (time > 1 && d < -0.05) {
            returnValue.rgb = stoppedTimeColor(returnValue.rgb);
        }
        returnValue.rgb += vec3(1.0,0.0,0.0) * distance(uv,vec2(0.5)) * 0.5 * abs(time_effect);

    }
    





    //if (distance(ndc,theworld_pos) < 0.2) { //distance(gl_FragCoord.xy / ScreenSize,vec2(1.0))
    //    //returnValue = vec4(1.0,0.0,0.0,1.0);
    //    float color = fractalField(gl_FragCoord.xy*4).a;
    //    color = threshold(smoothstep(0,1,color),0.5);
    //    returnValue = vec4(vec3(color),1.0);
    //}
    
    return returnValue;
}

void main(){
    fragColor = vec4(0);
    if (isControlColor()) {
        fragColor = special_code();
    } else {
        fragColor = normal_code();
    }


    
    

}
