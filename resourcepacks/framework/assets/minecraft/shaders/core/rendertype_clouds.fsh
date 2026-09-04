#version 330

#moj_import <minecraft:fog.glsl>


in float vertexDistance;
in vec4 vertexColor;
in vec3 worldpos;

out vec4 fragColor;

void main() {
    //24.5 -790.5

    vec4 color = vertexColor;
    color.a *= 1.0f - linear_fog_value(vertexDistance, 0, FogCloudsEnd);
    fragColor = color;
    fragColor.a *= smoothstep(20,40,distance(worldpos.xz,vec2(24.5,-790.5)));
    //if (fragColor.a < 0.01) discard;
}
