
float isMojangLogo(sampler2D Sampler0) {
    vec4 testMarker = texelFetch(Sampler0, ivec2(267, 146), 0);
    if (testMarker == vec4(1.0)) {
        //// Exclude bottom half or edge vertices to prevent weird remapping
        //if (UV0.y > 0.5) return -1.0;
        //else if ((vertexId == 0 || vertexId == 3) && UV0.y == 0.5) return -1.0;
        return 1.0;
    }
    return 0.0;
}

vec2 getBoxUV(vec2 uv, vec2 resolution, float scale) {
    float aspect = resolution.x / resolution.y;

    vec2 boxUV = uv;

    if (aspect > 1.0) {
        float boxWidth = resolution.y / resolution.x;
        float margin = (1.0 - boxWidth) * 0.5;
        boxUV.x = (uv.x - margin) / boxWidth;
    } else {
        float boxHeight = resolution.x / resolution.y;
        float margin = (1.0 - boxHeight) * 0.5;
        boxUV.y = (uv.y - margin) / boxHeight;
    }

    // scale around center
    boxUV = (boxUV - 0.5) / scale + 0.5;

    return boxUV;
}

vec3 drawFlames(vec2 uv, vec2 pos, vec2 size) {
    vec2 localUV = (uv - pos) / size + 0.5;

    if (localUV.x < 0.0 || localUV.x >= 1.0 ||
        localUV.y < 0.0 || localUV.y >= 1.0)
        return vec3(-1.0);

    ivec2 pixel = ivec2(floor(localUV * 20.0));

    switch(pixel.y * 20 + pixel.x) {
        case 47: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 52: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 67: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 73: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 84: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 87: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 88: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 93: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 104: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 108: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 109: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 112: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 113: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 116: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 125: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 128: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 129: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 131: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 132: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 133: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 136: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 145: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 146: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 148: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 149: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 150: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 151: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 152: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 153: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 155: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 156: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 165: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 166: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 167: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 168: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 169: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 170: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 171: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 172: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 173: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 175: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 176: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 186: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 187: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 188: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 189: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 190: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 191: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 192: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 193: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 195: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 196: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 205: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 206: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 207: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 208: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 209: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 210: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 211: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 212: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 213: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 214: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 215: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 216: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 224: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 225: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 226: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 227: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 228: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 229: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 230: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 231: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 232: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 233: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 234: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 235: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 236: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 244: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 245: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 246: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 247: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 248: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 249: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 250: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 251: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 252: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 253: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 254: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 255: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 256: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 264: return vec3(26/255.0, 86/255.0, 128/255.0);
        case 265: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 266: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 267: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 268: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 269: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 270: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 271: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 272: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 273: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 274: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 275: return vec3(40/255.0, 97/255.0, 137/255.0);
        case 284: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 285: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 286: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 287: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 288: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 289: return vec3(69/255.0, 126/255.0, 167/255.0);
        case 290: return vec3(69/255.0, 126/255.0, 167/255.0);
        case 291: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 292: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 293: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 294: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 295: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 305: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 306: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 307: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 308: return vec3(69/255.0, 126/255.0, 167/255.0);
        case 309: return vec3(69/255.0, 126/255.0, 167/255.0);
        case 310: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 311: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 312: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 313: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 314: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 326: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 327: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 328: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 329: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 330: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 331: return vec3(62/255.0, 117/255.0, 156/255.0);
        case 332: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 333: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 346: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 347: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 348: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 349: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 350: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 351: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 352: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 369: return vec3(46/255.0, 104/255.0, 144/255.0);
        case 370: return vec3(46/255.0, 104/255.0, 144/255.0);
    }

    return vec3(-1.0);
}
vec3 drawHood(vec2 uv, vec2 pos, vec2 size) {
    vec2 localUV = (uv - pos) / size + 0.5;

    if (localUV.x < 0.0 || localUV.x >= 1.0 ||
        localUV.y < 0.0 || localUV.y >= 1.0)
        return vec3(-1.0);

    ivec2 pixel = ivec2(floor(localUV * 20.0));

    switch(pixel.y * 20 + pixel.x) {
        case 29: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 30: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 49: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 50: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 68: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 71: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 88: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 91: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 107: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 112: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 127: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 129: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 130: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 132: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 146: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 148: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 151: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 153: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 166: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 168: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 171: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 173: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 185: return vec3(0/255.0, 186/255.0, 252/255.0);
        case 187: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 192: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 194: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 205: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 207: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 212: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 214: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 224: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 226: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 233: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 235: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 244: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 246: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 253: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 255: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 263: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 266: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 273: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 276: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 283: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 287: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 292: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 296: return vec3(0/255.0, 145/255.0, 196/255.0);
        case 304: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 307: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 312: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 315: return vec3(0/255.0, 145/255.0, 196/255.0);
        case 325: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 328: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 331: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 334: return vec3(0/255.0, 145/255.0, 196/255.0);
        case 346: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 349: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 350: return vec3(0/255.0, 69/255.0, 94/255.0);
        case 353: return vec3(0/255.0, 145/255.0, 196/255.0);
        case 367: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 368: return vec3(0/255.0, 160/255.0, 216/255.0);
        case 371: return vec3(0/255.0, 145/255.0, 196/255.0);
        case 372: return vec3(0/255.0, 145/255.0, 196/255.0);
        case 389: return vec3(0/255.0, 145/255.0, 196/255.0);
        case 390: return vec3(0/255.0, 145/255.0, 196/255.0);
    }

    return vec3(-1.0);
}
vec3 drawEyes(vec2 uv, vec2 pos, vec2 size) {
    vec2 localUV = (uv - pos) / size + 0.5;

    if (localUV.x < 0.0 || localUV.x >= 1.0 ||
        localUV.y < 0.0 || localUV.y >= 1.0)
        return vec3(-1.0);

    ivec2 pixel = ivec2(floor(localUV * 40.0));

    switch(pixel.y * 40 + pixel.x) {
        case 699: return vec3(242/255.0, 6/255.0, 51/255.0);
        case 700: return vec3(242/255.0, 6/255.0, 51/255.0);
        case 739: return vec3(242/255.0, 6/255.0, 51/255.0);
        case 740: return vec3(242/255.0, 6/255.0, 51/255.0);
        case 935: return vec3(16/255.0, 172/255.0, 226/255.0);
        case 936: return vec3(16/255.0, 172/255.0, 226/255.0);
        case 939: return vec3(19/255.0, 196/255.0, 36/255.0);
        case 940: return vec3(19/255.0, 196/255.0, 36/255.0);
        case 943: return vec3(255/255.0, 247/255.0, 0/255.0);
        case 944: return vec3(255/255.0, 247/255.0, 0/255.0);
        case 975: return vec3(16/255.0, 172/255.0, 226/255.0);
        case 976: return vec3(16/255.0, 172/255.0, 226/255.0);
        case 979: return vec3(19/255.0, 196/255.0, 36/255.0);
        case 980: return vec3(19/255.0, 196/255.0, 36/255.0);
        case 983: return vec3(255/255.0, 247/255.0, 0/255.0);
        case 984: return vec3(255/255.0, 247/255.0, 0/255.0);
        case 1097: return vec3(251/255.0, 106/255.0, 0/255.0);
        case 1098: return vec3(251/255.0, 106/255.0, 0/255.0);
        case 1101: return vec3(255/255.0, 0/255.0, 255/255.0);
        case 1102: return vec3(255/255.0, 0/255.0, 255/255.0);
        case 1137: return vec3(251/255.0, 106/255.0, 0/255.0);
        case 1138: return vec3(251/255.0, 106/255.0, 0/255.0);
        case 1141: return vec3(255/255.0, 0/255.0, 255/255.0);
        case 1142: return vec3(255/255.0, 0/255.0, 255/255.0);
        case 1259: return vec3(122/255.0, 18/255.0, 233/255.0);
        case 1260: return vec3(122/255.0, 18/255.0, 233/255.0);
        case 1299: return vec3(122/255.0, 18/255.0, 233/255.0);
        case 1300: return vec3(122/255.0, 18/255.0, 233/255.0);
    }

    return vec3(-1.0);
}


void tile(vec2 st, vec2 sc, out vec2 fp, out vec2 ip)
{
    st *= sc;
    fp = fract(st);
    ip = floor(st);
}

void tile(vec2 st, float sc, out vec2 fp, out vec2 ip)
{
    tile(st, vec2(sc), fp, ip);
}

vec2 random2(vec2 p)
{
    return fract(sin(vec2(
        dot(p, vec2(127.1,311.7)),
        dot(p, vec2(269.5,183.3))
    )) * 43758.5453);
}

// Returns distance to nearest cell point
float cellular1(vec2 fp)
{
    vec2 fst = fract(fp);
    vec2 ist = floor(fp);

    float m_dist = 1.0;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {

            vec2 neighbor = vec2(float(x), float(y));

            vec2 point = random2(ist + neighbor);
            point = 0.5 + 0.5 * sin(GameTime * 1200 + 6.2831 * point);
            // potential float fix

            vec2 diff = neighbor + point - fst;
            float dist = dot(diff, diff);
            //float dist = length(diff);
            // potential float fix

            m_dist = min(m_dist, dist);
        }
    }

    return m_dist;
}


float noise_multiple(float x){

    return -((sin(x)*sin(0.2*x)-cos(3*x)*.2+sin(.3*x)+2)/2);
}

#define brightness 3.
#define ray_brightness 5.
#define gamma 6.
#define spot_brightness 1.5
#define ray_density 6.
#define curvature 90.
#define red   0.2
#define green 3.6
#define blue  6.0
#define sin_freq 6.



float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 x)
{
    vec2 uv = x * 0.01 * 256.0;
    vec2 pixel = floor(uv);
    return hash12(pixel);
}

mat2 m2 = mat2( 0.80,  0.60, -0.60,  0.80 );
float fbm( in vec2 p )
{	
	float z=2.;
	float rz = 0.;
	p *= 0.25;
	for (float i= 1.;i < 6.;i++ )
	{
		rz+= abs((noise(p)-0.5)*2.)/z;
		z = z*2.;
		p = p*2.*m2;
	}
	return rz;
}

vec3 steve_logo_bg( vec2 fragCoord, float alpha, vec2 iResolution )
{
    float iTime = alpha*10;
	float t = -iTime*0.03;
    
	vec2 uv = fragCoord.xy / iResolution.xy-0.5;
	uv.x *= iResolution.x/iResolution.y;
	uv*= curvature*.05+0.0001;
	
	float r  = sqrt(dot(uv,uv));
	float x = dot(normalize(uv), vec2(.5,0.))+t;	
	float y = dot(normalize(uv), vec2(.0,.5))+t;
	
	x = fbm(vec2(y*ray_density*0.5,r+x*ray_density*.2));
	y = fbm(vec2(r+y*ray_density*0.1,x*ray_density*.5));

	
    float val;
    val = fbm(vec2(r+y*ray_density,r+x*ray_density-y));
	val = smoothstep(gamma*.02-.1,ray_brightness+(gamma*0.02-.1)+.001,val);
	val = sqrt(val);
	
	vec3 col = val/vec3(red,green,blue);
	col = clamp(1.-col,0.,1.);
	col = mix(col,vec3(1.),spot_brightness-r/0.1/curvature*200./brightness);
    col = clamp(col,0.,1.);
    col = pow(col,vec3(1.7));
	
	return col;
}

vec4 getCenterGlow(vec2 uv, vec2 screenSize, float alpha, vec2 fragCoord) {

    // Center in UV
    vec2 center = vec2(0.5, 0.4);

    // Aspect-corrected circular distance
    float aspect = screenSize.x / screenSize.y;

    // Scale X or Y to compensate for aspect ratio
    vec2 diff = uv - center;
    diff.x *= aspect;       // ensures circle, not ellipse

    // Distance from center, 0 to 1
    float d = length(diff);

    // Smooth gradient factor
    float t = smoothstep(0.2, 0.7, d);

    // Inner color (center)
    //vec4 inner = vec4(vec3(90, 99, 153) / 255, 1.0);
    vec4 inner = vec4(0,0,0,1);
    // Outer color (edges)
    vec4 outer = vec4(steve_logo_bg(fragCoord, alpha, screenSize), 0.0);
    //outer = vec4(0);
    // Interpolate
    return mix(inner, outer, t);
}


vec4 drawSteve(vec2 uv, vec2 resolution, float alpha, vec2 fragCoord) {
    uv.y -= 0.1;

    vec2 image_pos = vec2(0.5);
    vec2 image_size = vec2(0.7);

    float progress = alpha*smoothstep(0.1,0.4,alpha);

    vec2 pos = (fragCoord / resolution)*8;
    float y_offset = (noise_multiple(pos.x*5)) * (1 - smoothstep(0,1.0,progress)) / (4 * alpha);
    uv.y -= y_offset;

    vec2 BoxUV = getBoxUV(vec2(uv.x,1-uv.y),resolution,1);

    float gradient = (uv.x+uv.y)/2;
    gradient = pow(gradient,0.7);

    vec4 glow = getCenterGlow(uv, ScreenSize, alpha, fragCoord);
    glow.a = glow.a*smoothstep(0.1,0.4,alpha);
    //vec4 merged_glow = vec4(mix(fragColor.rgb,glow.rgb,glow.a),max(fragColor.a,glow.a));
    
    float globalScale = 0.7; 
    uv = (uv - 0.5) / globalScale + 0.5;
    uv = clamp(uv,0,1);
    float scale = smoothstep(0.4,0.7,progress);

    progress = smoothstep(0.2,0.6,progress);

    vec4 output_color = vec4(vec3(gradient)*1.3,smoothstep(0.1,0.5,alpha));
    vec3 logo_color = vec3(0);



    vec3 imageColor = drawEyes(BoxUV, image_pos, image_size);
    if (imageColor != vec3(-1)) {

        return mix(
            vec4(output_color.rgb * vec3(33, 107, 160) / 255, output_color.a),
            vec4(output_color.rgb * imageColor, output_color.a),
            smoothstep(0.5,0.8,alpha*smoothstep(0.1,0.4,alpha))
        );
    }
    imageColor = drawHood(BoxUV, image_pos, image_size);
    if (imageColor != vec3(-1)) {
        logo_color = imageColor;
        return vec4(output_color.rgb * logo_color, output_color.a);
    }

    imageColor = drawFlames(BoxUV, image_pos, image_size);
    if (imageColor != vec3(-1)) {
        logo_color = imageColor;
        return vec4(output_color.rgb * logo_color, output_color.a);
    }
    output_color = glow;
    output_color.a = max(smoothstep(0.4,0.7,alpha),output_color.a);

    
    float noise = cellular1(pos - vec2(0,y_offset*3));
    
    output_color.a = 1.0;
    if (noise > smoothstep(0.2,1,alpha)) {
        return vec4(0);
    }
    return output_color;
}

