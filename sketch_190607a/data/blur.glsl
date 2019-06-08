#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;


uniform float time;
uniform float pulse;
uniform vec2 screenSize;


const int MAX_MARCHING_STEPS = 2000;
const float POS_EPSILON = 0.001f;
const float NORMAL_EPSILON = 0.01f;
const float MAX_RAY_LEN = 50.0f;
const float PI = 3.1415926f;

float sphereSDF(vec3 p, vec3 spherePos, float radius) 
{
    return (length(p - spherePos) - radius);
}

float boxSDF(vec3 p, vec3 boxCenter, vec3 size)
{
    vec3 d = max(vec3(0.0f, 0.0f, 0.0f), abs(p - boxCenter) - size);
    return length(d); // min(d.x , min(d.y, d.z));
}

float spheroidSDF(vec3 pos, vec3 spheroidPos, vec3 size)
{
    vec3 d = pos - spheroidPos;

    vec3 d2 = (d * d) / (size * size);
    return d2.x + d2.y + d2.z - 1.0f;
}

float sphere1(vec3 pos)
{
    float t = (1 - pulse);
    return sphereSDF(pos, vec3(0.0f, 0.0f, -1.0f), 2.5f + t * 2);
}



float sphere2(vec3 pos)
{
    return sphereSDF(pos, vec3(1.0f, 0.0f, 0.0f), 4.0f + cos(2.0f + sin(pos.x) + cos(5.0f * pos.y) + cos(pos.z * 2.0f)));
}

const float boxY = -2.0f;

float boxPulse()
{
    return sin((pulse - 0.5f) * PI * 2);
}

vec3 boxSize()
{
    return vec3(1.0f, 1.0f + boxPulse(), 1.0f);
}

float boxShape1(vec3 pos)
{
    return boxSDF(pos, vec3(-5.0f, boxY + boxPulse(), 0.0f), boxSize());
}

float boxShape2(vec3 pos)
{
    return boxSDF(pos, vec3(5.0f, boxY + boxPulse(), 0.0f), boxSize());
}

float boxShape3(vec3 pos)
{
    return boxSDF(pos, vec3(0.0f, boxY + boxPulse(), 5.0f), boxSize());
}

float boxShape4(vec3 pos)
{
    return boxSDF(pos, vec3(0.0f, boxY + boxPulse(), -5.0f), boxSize());
}

float giraffeShape(vec3 pos, vec3 giraffePos)
{
    // eyes
    float dist = sphereSDF(pos, giraffePos + vec3(-1.0f, 2.0f, 1.0f), 1.0f);
    dist = min(dist, sphereSDF(pos, giraffePos + vec3(1.0f, 2.0f, 1.0f), 1.0f));

    // neck + head + torso
    dist = min(dist, spheroidSDF(pos, giraffePos + vec3(0.0f, -0.5f, 0.0f), vec3(2.0f, 2.0f, 3.0f)));
    dist = min(dist, spheroidSDF(pos, giraffePos + vec3(0.0f, -4.5f, 3.0f), vec3(2.0f, 8.0f, 2.0f)));
    dist = min(dist, spheroidSDF(pos, giraffePos + vec3(0.0f, -8.5f, 10.0f), vec3(5.0f, 7.0f, 10.0f)));

    // feet
    dist = min(dist, spheroidSDF(pos, giraffePos + vec3(4.0f, -12.5f, 15.0f), vec3(1.0f, 7.0f, 1.0f)));
    dist = min(dist, spheroidSDF(pos, giraffePos + vec3(-4.0f, -12.5f, 15.0f), vec3(1.0f, 7.0f, 1.0f)));
    dist = min(dist, spheroidSDF(pos, giraffePos + vec3(4.0f, -12.5f, 5.0f), vec3(1.0f, 7.0f, 1.0f)));
    dist = min(dist, spheroidSDF(pos, giraffePos + vec3(-4.0f, -12.5f, 5.0f), vec3(1.0f, 7.0f, 1.0f)));
    
    // tail
    dist = min(dist, spheroidSDF(pos, giraffePos + vec3(0.0f, -0.5f, 18.0f), vec3(0.5f, 5.0f, 0.5f)));
    
    return dist;
}


float giraffes(vec3 pos)
{
    return giraffeShape(pos, vec3(-5.0f, 5.0f, -15.0f));
}

float spheres(vec3 pos)
{
    float dist1 = sphere1(pos);
    float dist2 = sphere2(pos);
    return max(dist2,  dist2 - dist1);
}

float boxes(vec3 pos)
{
    float dist = boxShape1(pos);
    dist = min(dist, boxShape2(pos));
    dist = min(dist, boxShape3(pos));
    dist = min(dist, boxShape4(pos));
    return dist;
}



float sceneSDF(vec3 pos)
{
    float dist = spheres(pos);
    dist = min(dist, boxes(pos));
    dist = min(dist, giraffes(pos));
    return dist;
}

vec3 objectColor(float dist, vec3 col)
{
    return (1-dist) * col;
}

vec3 sceneColor(vec3 pos)
{
    vec3 col1 = objectColor(sphere1(pos), vec3(1.0f, 0.0f, -0.1f));
    vec3 col2 = objectColor(sphere2(pos), vec3(0.0f, 1.0f, 0.0f));
    vec3 col = clamp(col1 + col2, 0.0f, 1.0f);
    col += clamp(objectColor(boxes(pos), vec3(0.0f, 0.0f, 1.0f)), 0.0f, 1.0f);

    float gDist = giraffes(pos);
    if(gDist < 0.1f)
    {
        pos *= 0.4f;
        float a = clamp(sin(pos.x * 2.0f + pos.y) + cos(pos.x * 3.0f +  pos.y * 5.0f + pos.z * 11.0f) + cos(pos.z * 4.0f + pos.x * 7.0f), 0.0f, 1.0f);
        col = a * vec3(1.0f, 1.0f, 0.0f);
    } 
    return col;
}

vec3 estimateNormal(vec3 p) 
{
    return normalize(vec3(
        sceneSDF(vec3(p.x + NORMAL_EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - NORMAL_EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + NORMAL_EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - NORMAL_EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z  + NORMAL_EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - NORMAL_EPSILON))
    ));
}

float march(vec3 pos, vec3 rayDir)
{
    float depth = 0.0f;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) 
    {
        float dist = sceneSDF(pos + depth * rayDir);
        if (dist < POS_EPSILON)
        {
            // We're inside the scene surface!
            return depth;
        }
        // Move along the view ray
        depth += dist;

        if (depth >= MAX_RAY_LEN) 
        {
            // Gone too far; give up
            return MAX_RAY_LEN;
        }
    }
    return depth;
}

void main()
{
    float camDist = -40.0f;
    vec3 sunDir = normalize(vec3(sin(time), cos(time), 1.0f));
    vec3 moonDir = normalize(vec3(0.0f, 1.0f, -0.2f));
    float cameraT = (time + vertTexCoord.y * 1);
    vec3 cameraPos = vec3(sin(cameraT) * camDist, 0.0f, cos(cameraT) * camDist);
    vec3 rayTarget = vec3(0.0f, 0.0f, 0.0f);
    vec3 cameraRayDir = normalize(rayTarget - cameraPos);
    vec3 cameraGlobalUp = vec3(0, 1, 0);
    vec3 cameraRight = normalize(cross(cameraRayDir, cameraGlobalUp));
    vec3 cameraUp = cross(cameraRight, cameraRayDir);
    vec2 screenOffset = (vertTexCoord.xy - 0.5f) * screenSize;
    vec3 screenDir = normalize(cameraRight * screenOffset.x + cameraUp * screenOffset.y + cameraRayDir * 1.5f);
    vec3 rayDir = screenDir;

    cameraPos += sin(time * 3) * cameraRight * 2 + pulse * cameraRayDir * 5;

    vec3 c = vec3(0.0f, 0.0f, 0.0f);

    float dist = march(cameraPos, rayDir);

    if(dist < MAX_RAY_LEN)
    {
        vec3 hitPos = cameraPos + rayDir * dist;
        vec3 normal = estimateNormal(hitPos);
        vec3 baseColor = sceneColor(hitPos);
        c = baseColor * clamp(dot(sunDir, -normal), 0.0f, 1.0f) * 0.9f + 0.1f;
        c = c + clamp(dot(moonDir, normal), 0.0f, 1.0f) * vec3(0.1f, 0.1f, 0.3f);
    }

    gl_FragColor = vec4(c, 1.0f);
}