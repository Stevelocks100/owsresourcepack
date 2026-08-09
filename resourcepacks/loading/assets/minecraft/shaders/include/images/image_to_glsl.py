from PIL import Image

IMG_PATH = "assets/minecraft/shaders/include/images/eyes.png"
SIZE = 40
# should only work with 16x16 now 20x20 lol
img = Image.open(IMG_PATH).convert("RGBA")

if img.size != (SIZE, SIZE):
    raise ValueError(f"Image must be {SIZE}x{SIZE}")

cases = []

for y in range(SIZE):
    for x in range(SIZE):
        r, g, b, a = img.getpixel((x, y))

        if a == 0:
            continue

        idx = y * SIZE + x

        cases.append(
            f"        case {idx}: return vec3({r}/255.0, {g}/255.0, {b}/255.0);"
        )

glsl = f"""vec3 drawImage(vec2 uv, vec2 pos, vec2 size) {{
    vec2 localUV = (uv - pos) / size + 0.5;

    if (localUV.x < 0.0 || localUV.x >= 1.0 ||
        localUV.y < 0.0 || localUV.y >= 1.0)
        return vec3(-1.0);

    ivec2 pixel = ivec2(floor(localUV * {SIZE}.0));

    switch(pixel.y * {SIZE} + pixel.x) {{
{chr(10).join(cases)}
    }}

    return vec3(-1.0);
}}
"""

with open("generated.glsl", "w") as f:
    f.write(glsl)

print("Generated generated.glsl")