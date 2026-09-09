#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0;


out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;

out float is_theworld;
out vec2 theworld_pos;
out vec4 raw_vertexColor;

vec2[] theworld_corners = vec2[](
    vec2(0.0, 1.0),
    vec2(0.0, 0.0),
    vec2(1.0, 0.0),
    vec2(1.0, 1.0)
);


void main() {

    raw_vertexColor = Color;

    vec3 pos = Position;

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;


    vec4 shader_check = round(texture(Sampler0, UV0)*255);
    theworld_pos = vec2(0);
    is_theworld = 0;
    if (shader_check == vec4(31,51,14,231)) {
        theworld_pos = gl_Position.xy / gl_Position.w;
        is_theworld = 1;
        if (gl_Position.z < 0) {
            is_theworld = 2;
        }
        
        vec2 one_pixel = vec2(2) / ScreenSize;
        gl_Position = vec4(-1 + (vec2(2,2) + theworld_corners[gl_VertexID % 4] * vec2(2,1)) * one_pixel , -1.0, 1.0);
        //gl_Position.xy = vec2(theworld_corners[gl_VertexID % 4]*3);

    }


}
