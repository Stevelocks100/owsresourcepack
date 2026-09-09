#version 150


uniform sampler2D MainSampler;


#moj_import <minecraft:globals.glsl>
#moj_import <theworld:helper.glsl>


in vec2 texCoord;

out vec4 fragColor;



void main(){

        fragColor = vec4(encode_time(GameTime * 24000),1.0);
    

}
