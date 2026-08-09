#version 150

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl
#moj_import <minecraft:dynamictransforms.glsl>

#moj_import <minecraft:globals.glsl>

#moj_import <minecraft:draw_logo.glsl>



uniform sampler2D Sampler0;

in vec2 texCoord0;
in vec4 vertexColor;

flat in float LogoTest;

out vec4 fragColor;




void main() {

    if (LogoTest == 1.0) {
        vec2 uv = gl_FragCoord.xy / ScreenSize;

        fragColor = drawSteve(uv,ScreenSize,vertexColor.a, gl_FragCoord.xy);
        fragColor.rgb /= 2;
        if (fragColor.a == 0.0) {
            discard;
        }
        return;
    }

    vec4 color = texture(Sampler0, texCoord0) * vertexColor;
    
    if (color.a == 0.0) {
        discard;
    }
    
    fragColor = color * ColorModulator;
    //fragColor = texture(Sampler0,gl_FragCoord.xy / ScreenSize);



   

}
