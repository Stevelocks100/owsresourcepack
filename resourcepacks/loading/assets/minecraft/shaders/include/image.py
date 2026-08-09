import moderngl
import numpy as np
from PIL import Image


VERT_SHADER = """
#version 330

in vec2 in_pos;
out vec2 v_uv;

void main() {
    v_uv = (in_pos + 1.0) * 0.5;
    gl_Position = vec4(in_pos, 0.0, 1.0);
}
"""


def load_glsl(path):
    with open(path, "r") as f:
        return f.read()


def build_fragment_shader(user_code):
    return f"""
#version 330

uniform vec2 resolution;
uniform vec2 ScreenSize;
uniform float GameTime;

in vec2 v_uv;
out vec4 fragColor;

// --- user code ---
{user_code}

// --- main wrapper ---
void main() {{
    vec2 fragCoord = v_uv * resolution;
    vec2 uv = fragCoord / resolution;

    fragColor = drawSteve(uv, resolution, 1.0, fragCoord);
}}
"""

def render(width=512, height=512, output="output.png"):
    ctx = moderngl.create_standalone_context()

    quad = np.array([
        -1.0, -1.0,
         1.0, -1.0,
        -1.0,  1.0,
         1.0,  1.0,
    ], dtype="f4")

    vbo = ctx.buffer(quad.tobytes())

    user_code = load_glsl("draw_logo.glsl")
    frag_shader = build_fragment_shader(user_code)

    prog = ctx.program(
        vertex_shader=VERT_SHADER,
        fragment_shader=frag_shader,
    )

    vao = ctx.simple_vertex_array(prog, vbo, "in_pos")

    fbo = ctx.simple_framebuffer((width, height))
    fbo.use()


    prog["resolution"].value = (width, height)
    # remove later
    prog["ScreenSize"].value = (width, height)
    prog["GameTime"].value = 0.5

    ctx.clear(0.0, 0.0, 0.0, 1.0)
    vao.render(mode=moderngl.TRIANGLE_STRIP)

    data = fbo.read(components=4, alignment=1)
    image = Image.frombytes("RGBA", (width, height), data)
    image = image.transpose(Image.FLIP_TOP_BOTTOM)
    image.save(output)

    print(f"Saved {output}")


if __name__ == "__main__":
    render(2560, 1440, "output.png")