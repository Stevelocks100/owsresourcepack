#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <corruption:stevebase/skybox.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
#ifdef PER_FACE_LIGHTING
out vec4 vertexPerFaceColorBack;
out vec4 vertexPerFaceColorFront;
#else
out vec4 vertexColor;
#endif
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec3 pos;

void main() {
    pos = Position;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

#ifdef PER_FACE_LIGHTING
    vec2 light = minecraft_compute_light(Light0_Direction, Light1_Direction, Normal);
    vertexPerFaceColorBack = minecraft_mix_light_separate(-light, Color);
    vertexPerFaceColorFront = minecraft_mix_light_separate(light, Color);

    if (apply_base_skybox(Position + CameraBlockPos - CameraOffset) > 0) {
        vertexPerFaceColorBack.rgb = mix(
            vertexPerFaceColorBack.rgb,
            applyLights(vertexPerFaceColorBack.rgb, Normal),
            apply_base_skybox(Position + CameraBlockPos - CameraOffset)
        );
        vertexPerFaceColorFront.rgb = mix(
            vertexPerFaceColorFront.rgb,
            applyLights(vertexPerFaceColorFront.rgb, Normal),
            apply_base_skybox(Position + CameraBlockPos - CameraOffset)
        );
    }
#elif defined(NO_CARDINAL_LIGHTING)
    vertexColor = Color;
    if (apply_base_skybox(Position + CameraBlockPos - CameraOffset) > 0) {
        vertexColor.rgb = mix(
            vertexColor.rgb,
            applyLights(vertexColor.rgb, Normal),
            apply_base_skybox(Position + CameraBlockPos - CameraOffset)
        );
    }
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    if (apply_base_skybox(Position + CameraBlockPos - CameraOffset) > 0) {
        vertexColor.rgb = mix(
            vertexColor.rgb,
            applyLights(vertexColor.rgb, Normal),
            apply_base_skybox(Position + CameraBlockPos - CameraOffset)
        );
    }
#endif
#ifndef EMISSIVE
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
#endif
    overlayColor = texelFetch(Sampler1, UV1, 0);

    texCoord0 = UV0;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif
}
