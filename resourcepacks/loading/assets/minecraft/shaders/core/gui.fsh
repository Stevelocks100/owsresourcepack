#version 330

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>

#moj_import <minecraft:draw_logo.glsl>

in vec4 vertexColor;

out vec4 fragColor;

bool isLoadingScreen(vec4 color) {
    return (color.r == 239.0 / 255.0) && (color.g == 50.0 / 255.0) && (color.b == 61.0 / 255.0);
}



void main() {
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
    if (isLoadingScreen(fragColor)) {
        vec2 uv = gl_FragCoord.xy / ScreenSize;

        fragColor = drawSteve(uv,ScreenSize,color.a, gl_FragCoord.xy);
        fragColor.rgb /= 2;
        if (fragColor.a == 0.0) {
            discard;
        }
    }

}
