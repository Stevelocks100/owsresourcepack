#moj_import <framework:ray_march.glsl>
#moj_import <framework:wood_texture.glsl>
#moj_import <framework:noise.glsl>
#moj_import <minecraft:globals.glsl>

float mapv2(vec3 p) {
    vec3 cell_p = mod(p,vec3(6));
    vec3 d = vec3(0);
    d.y = p.y + 112;

    if (cell_p.x >= 0 && cell_p.x < 0.5) {
        d.x = -cell_p.x;
    } else if (0.5 < cell_p.x && cell_p.x < 6) {
       d.x = -abs(-cell_p.x + 3.5) + 2.5; 
    }

    if (cell_p.z >= 0 && cell_p.z < 0.5) {
        d.z = -cell_p.z;
    } else if (0.5 < cell_p.z && cell_p.z < 6) {
       d.z = -abs(-cell_p.z + 3.5) + 2.5; 
    }
    if (d.x < 0 || d.z < 0) {
        return max(max(d.x,d.z),d.y);
    } else {
        return distance(
            vec2(
                distance(d.xz,vec2(0)),
                d.y
                ),
            vec2(0)
            );
    }
    

}

float mapv3(vec3 p) {
    
    return min(sdRoundedCylinder( p - vec3(-31, -120, -590), 2, 1, 4 ),sdTorus( p - vec3(-40, -120, -590), vec2(3,1) ));
}

float map(vec3 p) {

    vec2 cell = vec2(4.0);
    p.xz -= cell * floor(p.xz / cell + 0.5);


    float column = sdBox(
        p - vec3(0.5, -162.0, 0.5),
        vec3(0.5, 100.0, 0.5)
    );


    float below = (p.y + 112.0);


    return max(column, below);
}

float fogDensity(vec3 p, float time) {

    float height = clamp((-p.y - 112.0) / 12.0, 0.0, 1.0);


    float n = noise(p * 0.04);
    n = n * n;
    n = n * 0.5 + 0.5;


    float sdf = map(p);
    float surface = exp(-abs(sdf) * 3.0);

    return height * n * (0.3 + surface);
}

vec4 voidRaycast(
    vec3 rayOrigin,
    vec3 rayDir,
    float time,
    float y,
    vec3 CameraPos,
    vec4 vertex_color
){
    vec4 return_color = vec4(1,0,0,0);
    float t = 0;
    float tMax = 50;
    
    float fog = 0.0;
    float transmittance = 1.0;

    float fade_to_black = smoothstep(-162.0, -200.0, CameraPos.y);
    if (fade_to_black == 1.0) {
        return vec4(0);
    }
    for (int i = 0; i < 64; i++) {
        vec3 p = rayOrigin + rayDir * t;

        float d = map(p);

        // fog
        float stepLen = clamp(d, 0.05, 1.0);
        float density = fogDensity(p+vec3(time,0,0), time);

        if (d > 0.0) {
            fog += density * stepLen * transmittance;
            transmittance *= exp(-density * stepLen);
            if (transmittance < 0.01) break;
        }

        // hit
        if (d < 0.01) {
            float distanceTravelled = distance(rayOrigin,p);
            distanceTravelled = smoothstep(50,30,distanceTravelled);

            vec3 lp = p - vec3(0.5, 0.0, 0.5);

            vec2 uv = round(vec2(lp.x + lp.z, lp.y) * 16.0) / 16.0;
            vec3 col = wood(uv) / 1.3;
            // col = mix(col, col * vertex_color.rgb, 0.5); //adds lighting that probably makes everything more inconsistent

            float spruce_mix = smoothstep(-113,-112,lp.y);
            vec3 spruce_color = vec3(120, 91, 53) / 255;
            //vec3(120, 91, 53)
            float edgeWidth = 0.4;

            float fx = abs(fract(lp.x) - 0.5);
            float fz = abs(fract(lp.z) - 0.5);

            float edge = step(0.5 - edgeWidth, max(fx, fz));

            spruce_color = mix(vec3(97, 81, 45) / 255, spruce_color, edge);
            //spruce_color = mix(spruce_color, spruce_color * vertex_color.rgb, 0.9);
            spruce_color = spruce_color * 0.0;
            col = mix(col,spruce_color,spruce_mix);


            col = mix(col, vec3(fog / 4.0), clamp(fog, 0.0, 1.0));
            

            

            //#7F5E38
            //vec3(127, 94, 56)

            //#735934
            //vec3(115, 89, 52)

            vec4 return_color = vec4(col, max(distanceTravelled,fog));
            return_color.a = max(return_color.a, fade_to_black);
            return_color.rgb = mix(return_color.rgb, vec3(0.0), fade_to_black);
            return return_color;
        }
        
        if (p.y > -110 && rayDir.y > 0.1) break;

        t += stepLen;
        if (t > tMax) break;
    }
    vec3 fogColor = vec3(fog/4);
    float fogAlpha = clamp(fog, 0.0, 1.0);
    vec4 return_fog_color = vec4(fogColor, fogAlpha);
    
    return_fog_color.a = max(return_fog_color.a,fade_to_black);
    return_fog_color.rgb = mix(return_fog_color.rgb,vec3(0),fade_to_black);
    return return_fog_color;
    
}
