#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <framework:possessed.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;


out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec3 pos;
flat out mat4 inverseViewMatrix;
flat out int isFramework;
out vec2 face_coords;

vec2[] corners = vec2[](
    vec2(1.0, 1.0),
    vec2(1.0, -1.0),
    vec2(-1.0, -1.0),
    vec2(-1.0, 1.0)
);

vec2[] screen_corners = vec2[](
    vec2(-1.0, 1.0),
    vec2(-1.0, -1.0),
    vec2(1.0, -1.0),
    vec2(1.0, 1.0)
);


void main() {
    inverseViewMatrix = inverse(ProjMat * ModelViewMat);
    pos = Position;
    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

    isFramework = 0;

    face_coords = corners[gl_VertexID % 4];

    vec4 shader_check = round(texture(Sampler0,UV0)*255);
    if (shader_check.rgb == vec3(154,78,78)) {
        pos.xz = corners[gl_VertexID % 4]*10000;
        isFramework = 1;
    }

    shader_check = round(texture(Sampler0,UV0 + (vec2(8,0) / textureSize(Sampler0,0)))*255);
    if (shader_check == vec4(180,187,137,102)) {
        float size = abs(max(pos.y,-0.001));
        pos.y = max(pos.y,5);
        size /= 20;
        size = pow(size,3);
        size = max(size,0.0001);

        vec2 corner_correction = pos.y < 0 ? vec2(1,1) : vec2(-1,1);
        corner_correction = vec2(-1,1);
        pos.xz += corners[gl_VertexID % 4] * corner_correction / size;
        isFramework = 3;
    }
    
    
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    if (isFramework == 1 && pos.y > -0.1) {
        gl_Position = vec4(screen_corners[gl_VertexID % 4],0,1);

    }
    if (isOverlay(Sampler0,UV0) && isFramework == 0) {
        isFramework = 2;
        gl_Position = vec4(screen_corners[gl_VertexID % 4],0,1);
    }
   

    

    

    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
}