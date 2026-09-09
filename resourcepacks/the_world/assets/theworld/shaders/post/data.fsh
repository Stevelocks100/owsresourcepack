#version 150

uniform sampler2D DataSampler;
uniform sampler2D MainSampler;


#moj_import <minecraft:globals.glsl>
#moj_import <theworld:helper.glsl>


in vec2 texCoord;

out vec4 fragColor;



void main(){

    fragColor = vec4(1);
    if (int(floor(gl_FragCoord.y)) == 0) {
        //int pixel = int(gl_FragCoord.x);
        //switch (pixel) {
        //    case 0:
        //        if (is_active()) {
        //            fragColor = vec4(1.0);
        //        } else {
        //            fragColor = vec4(0.0,0.0,0.0,1.0);
        //        }
        //        break;

        //    case 1:
        //        if (!is_active()) {
        //            fragColor = vec4(encode_time(GameTime * 24000),1.0);
        //        } else {
        //            fragColor = texture(DataSampler,texCoord);
        //        }
        //        break;
        //    
        //    case 2:
        //        fragColor = vec4(encode_time(GameTime * 24000),1.0);
        //        break;
        //    
        //}
        fragColor = vec4(1.0,0.0,0.0,1.0);
    }
    
    fragColor = texture(MainSampler,texCoord);

    

}
