#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>




uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in float is_theworld;
in vec2 theworld_pos;
in vec4 raw_vertexColor;

out vec4 fragColor;


void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);

    if (is_theworld > 0 && sphericalVertexDistance < 40) {
        float range = 1.4;
        vec2 ndc = (theworld_pos / range + 1.0) * 0.5;
        if (ivec2(gl_FragCoord.xy) == ivec2(2,2)) {
            fragColor = vec4(vec3(156,53,97)/255,1);
            if (is_theworld > 1) {
                fragColor = vec4(vec3(156,54,97)/255,1);
            }
        } else {
            fragColor = vec4(raw_vertexColor.r,ndc,1);
        }
    }
    
    
    
}
