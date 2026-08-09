#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <framework:framework.glsl>
#moj_import <gphoenix:blade.glsl>
#moj_import <framework:possessed.glsl>
#moj_import <skybox:skybox.glsl>
#moj_import <corruption:missing.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec3 pos;
flat in mat4 inverseViewMatrix;
flat in int isFramework;
in vec2 face_coords;



out vec4 fragColor;

void main() {
    

    vec3 CameraPos = vec3(CameraBlockPos) - CameraOffset;
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;

    if (isFramework != 0) {
        switch (isFramework) {
            case 1:
                vec2 ndc = ((gl_FragCoord.xy / ScreenSize) * 2 - 1);
                vec4 nearProjection = inverseViewMatrix * vec4(ndc, -1.0, 1.0);
                vec4 farProjection  = inverseViewMatrix * vec4(ndc,  1.0, 1.0);

                nearProjection /= nearProjection.w;
                farProjection  /= farProjection.w;

                //vec3 rayDir = normalize(worldFar.xyz - worldNear.xyz);
                //vec3 rayOrigin = cameraWorldPos;

                float normal_spherical_distance = fog_spherical_distance(pos);
                float normal_cylindrical_distance = fog_cylindrical_distance(pos);

                vec3 rayOrigin = nearProjection.xyz + CameraPos;  
                vec3 rayDir = normalize(farProjection.xyz - nearProjection.xyz);
                fragColor = voidRaycast(rayOrigin,rayDir,GameTime * 1200,pos.y,CameraPos,vertexColor);
                fragColor = mix(fragColor,
                    apply_fog(fragColor, normal_spherical_distance, normal_cylindrical_distance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor),
                    smoothstep(-111,-105,CameraPos.y)
                );

                if (fragColor.a < 0.01) {
                    discard;
                }
                return;

            case 2:
                if (fog_spherical_distance(pos) > 30) discard;
                fragColor = possessed_overlay(texCoord0,GameTime*1200,Sampler0, fog_spherical_distance(pos),gl_FragCoord.xy/ScreenSize);
                if (fragColor.a < 0.2) discard;
                return;

            case 3:
                fragColor = vec4(0.4705882353, 0.6549019608, 1.0 ,1);
                // #78A7FF is sky
                break;

                // ok for some reason this one fucking switch case causes the game to silently crash
                // but only if you use a return in here while there's a break below it somewhere.
                // i dont know how the fuck this is possible but it is
                // something about this particular bit of code is wildly unstable which is really fucking weird
                // maybe avoid using any additional switch cases, and DO NOT put break; below a return;

        }
    }
    
    

    if (color.a < 0.1) {
        discard;
    }
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
    fragColor = skybox(Sampler0, texCoord0, pos, GameTime, fragColor);

    


    vec4 shader_check = round(texture(Sampler0,texCoord0)*255);
    if (shader_check == vec4(41,70,62,87)) {
        fragColor = BladeEffect(round(face_coords*16)/16, GameTime*1200);
        if (fragColor.a < 0.15) discard;

        return;
    }



    if (shader_check == vec4(84, 99, 13, 78)) {

        vec3 ro = CameraBlockPos - CameraOffset + pos;
        vec3 rd = normalize(pos);
        fragColor = vec4(missing(ro,rd,gl_FragCoord.xy),1.0);
        return;
        
    }

    shader_check = round(texture(Sampler0,texCoord0 + (vec2(32,0) / textureSize(Sampler0,0)))*255);
    if (shader_check == vec4(47,208,165,119)) {
        fragColor = texture(Sampler0,texCoord0);
        return;
    }
    shader_check = round(texture(Sampler0,texCoord0 + (vec2(128,0) / textureSize(Sampler0,0)))*255);
    if (shader_check.rgb == vec3(130,160,109)) {
        fragColor = texture(Sampler0,texCoord0);
        return;

    }

    

    

    
}