#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <corruption:missing.glsl>


uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#ifdef PER_FACE_LIGHTING
in vec4 vertexPerFaceColorBack;
in vec4 vertexPerFaceColorFront;
#else
in vec4 vertexColor;
#endif
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec3 pos;

out vec4 fragColor;

void main() {

    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
#ifdef PER_FACE_LIGHTING
    color *= (gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack) * ColorModulator;
#else
    color *= vertexColor * ColorModulator;
#endif
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    color *= lightMapColor;
#endif
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);

    if (isSkin(Sampler0)) {
        vec3 skin_color = texture(Sampler0,texCoord0).rgb;
        vec3 ro = CameraBlockPos - CameraOffset + pos;
        vec3 rd = normalize(pos);
        for (int i = 0; i < 8; i++) {
            color = texture(Sampler0, texCoord0);
            vec4 skin_check = texelFetch(Sampler0,ivec2(i,7),0);
            if (skin_check == color) {
                fragColor = vec4(missing(ro,rd,gl_FragCoord.xy),1.0);
                fragColor.rgb += skin_color;
            }
            
        }
        
    }
}
