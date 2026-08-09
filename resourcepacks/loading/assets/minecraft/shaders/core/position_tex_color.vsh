#version 150

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl and projection.glsl
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>

#moj_import <minecraft:draw_logo.glsl>

uniform sampler2D Sampler0;

in vec3 Position;
in vec2 UV0;
in vec4 Color;

out vec2 texCoord0;
out vec4 vertexColor;

flat out float LogoTest;

vec2[] corners = vec2[](
    vec2(-1.0, 1.0),
    vec2(-1.0, -1.0),
    vec2(1.0, -1.0),
    vec2(1.0, 1.0)
);
int vertexId = gl_VertexID % 4;

void main() {

    LogoTest = isMojangLogo(Sampler0);
    
    texCoord0 = UV0;
    vertexColor = Color;
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    //if (gl_Position.x < 0) {
    //    gl_Position.x = -1;
    //} else {
    //    gl_Position.x = 1;
    //}
    //if (gl_Position.y < 0) {
    //    gl_Position.y = -1;
    //} else {
    //    gl_Position.y = 1;
    //}

    if (LogoTest == 1.0) {
        gl_Position = vec4(corners[vertexId],1.0, 1.0);
    }


}
