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
const float MAX_RAY_LEN = 100.0f;
const float PI = 3.1415926f;

// polynomial smooth min (k = 0.1);
float sminCubic( float a, float b )
{
    float k = 0.8f;
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

float sinPulse()
{
    return sin((pulse - 0.5f) * PI * 2);
}

float sphereSDF(vec3 p, vec3 spherePos, float radius) 
{
    return (length(p - spherePos) - radius);
}

float boxSDF(vec3 p, vec3 boxCenter, vec3 size)
{
    vec3 d = max(vec3(0.0f, 0.0f, 0.0f), abs(p - boxCenter) - size);
    return length(d); // sminCubic(d.x , sminCubic(d.y, d.z));
}

float spheroidSDF(vec3 pos, vec3 spheroidPos, vec3 size)
{
    size.y *= 1.2f + sinPulse() * 0.2f;
    size.x *= 1.25f + sinPulse() * 0.3f;
    size.x *= (1.0f + sin(pos.y + time * 10) * 0.1f);
    size.z *= (1.0f + sin(pos.y + time * 10) * 0.1f);
    vec3 d = pos - spheroidPos;

    vec3 d2 = (d * d) / (size * size);
    return d2.x + d2.y + d2.z - 1.0f;
}

float sphere1(vec3 pos)
{
    float t = (1 - pulse);
    return sphereSDF(pos, vec3(0.0f, 0.0f, -1.0f), 2.5f + t * 2);
}

float sphere3(vec3 pos)
{
    float d = sphere1(pos - vec3(-6.0f, 2.0f, -5.0f));
    return min(d, sphere1(pos - vec3(6.0f, 2.0f, 20.0f)));
}

float sphere2(vec3 pos)
{
    return sphereSDF(pos, vec3(1.0f, 0.0f, 0.0f), 4.0f + cos(2.0f + sin(pos.x) + cos(5.0f * pos.y) + cos(pos.z * 2.0f)));
}

float sphere4(vec3 pos)
{
    float d = sphere2(pos - vec3(-6.0f, 2.0f, -5.0f));
    return min(d, sphere2(pos - vec3(6.0f, 2.0f, 20.0f)));
}

const float boxY = 0.0f;

float boxPulse()
{
    return sinPulse();
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

float giraffeShape(vec3 pos, vec3 giraffePos, out int hitType)
{
    giraffePos.y += sin(time * 4 + vertTexCoord.y * 10) * 0.5f;

    float yTwist = sin(clamp(pos.y * 0.5f, 0, 10) / 10);
    giraffePos.z += (sinPulse() - 1) * (yTwist) * 10;

    float headOffset =  + 4.0f * (1 + sinPulse());

    // eyes
    float dist = spheroidSDF(pos, giraffePos + vec3(-1.0f, 2.0f + headOffset, 1.0f - abs(sinPulse() * 1.5f)), vec3(1.0f, 1.0f, 1.0f));
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(1.0f, 2.0f + headOffset, 1.0f - abs(sinPulse() * 1.5f)),  vec3(1.0f, 1.0f, 1.0f)));
    
    float minDist = dist;

    float pupilDist = spheroidSDF(pos, giraffePos + vec3(-1.0f, 2.0f + headOffset, 0.2f - abs(sinPulse() * 1.5f * 2)),  vec3(1.0f, 1.0f, 1.0f) * 0.5f);
    pupilDist = sminCubic(pupilDist, spheroidSDF(pos, giraffePos + vec3(1.0f, 2.0f + headOffset, 0.2f - abs(sinPulse() * 1.5f * 2)),  vec3(1.0f, 1.0f, 1.0f) * 0.5f));
    
    dist = sminCubic(dist, pupilDist);

    // neck + head + torso
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(0.0f, -0.5f + headOffset, 0.0f), vec3(2.0f, 2.0f, 3.0f)));
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(0.0f, -4.5f + headOffset / 2, 3.0f), vec3(2.0f, 8.0f + headOffset * 0.33f, 2.0f)));
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(0.0f, -8.5f, 10.0f), vec3(5.0f, 7.0f, 10.0f)));

    // feet
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(4.0f, -12.5f, 15.0f), vec3(1.0f, 7.0f, 1.0f)));
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(-4.0f, -12.5f, 15.0f), vec3(1.0f, 7.0f, 1.0f)));
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(4.0f, -12.5f, 5.0f), vec3(1.0f, 7.0f, 1.0f)));
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(-4.0f, -12.5f, 5.0f), vec3(1.0f, 7.0f, 1.0f)));
    
    // tail
    dist = sminCubic(dist, spheroidSDF(pos, giraffePos + vec3(0.0f, -0.5f, 18.0f), vec3(0.5f, 5.0f, 0.5f)));

    hitType = minDist == dist ? 0 : pupilDist == dist ? 2 : 1;

    return dist;
}


float giraffes(vec3 pos, out int hitType)
{
    int hitType1 = 1;
    int hitType2 = 1;
    float dist1 = giraffeShape(pos, vec3(-6.0f, 0.0f, -15.0f), hitType1);
    float dist2 = giraffeShape(pos, vec3(6.0f, 0.0f, 10.0f), hitType2);

    float dist = sminCubic(dist1, dist2);
    hitType = dist == dist1 ? hitType1 : hitType2;
    return dist;
}

float spheres(vec3 pos)
{
    float dist1 = sphere3(pos);
    float dist2 = sphere4(pos);
    return max(dist2,  dist2 - dist1);
}

float boxes(vec3 pos)
{
    float dist = boxShape1(pos - vec3(-6.0f, 2.0f, -5.0f));
    dist = min(dist, boxShape2(pos - vec3(-6.0f, 2.0f, -5.0f)));
    dist = min(dist, boxShape3(pos - vec3(-6.0f, 2.0f, -5.0f)));
    dist = min(dist, boxShape4(pos - vec3(-6.0f, 2.0f, -5.0f)));

    dist = min(dist, boxShape1(pos));
    dist = min(dist, boxShape2(pos - vec3(6.0f, 2.0f, 20.0f)));
    dist = min(dist, boxShape3(pos - vec3(6.0f, 2.0f, 20.0f)));
    dist = min(dist, boxShape4(pos - vec3(6.0f, 2.0f, 20.0f)));
    return dist;
}



float sceneSDF(vec3 pos)
{
    int dummy = 0;
    float dist = spheres(pos);
    dist = min(dist, boxes(pos));
    dist = min(dist, giraffes(pos, dummy));
    return dist;
}

vec3 objectColor(float dist, vec3 col)
{
    return (1-dist) * col;
}

vec3 sceneColor(vec3 pos, vec3 normal)
{
    vec3 sunDir = normalize(vec3(sin(time), cos(time), 1.0f));
    vec3 moonDir = normalize(vec3(0.0f, 1.0f, -0.2f));

    vec3 col1 = objectColor(sphere3(pos), vec3(1.0f, 0.0f, -0.1f));
    vec3 col2 = objectColor(sphere4(pos), vec3(0.0f, 1.0f, 0.0f));

    vec3 col = clamp(col1 + col2, 0.0f, 1.0f);
    col += clamp(objectColor(boxes(pos - vec3(-6.0f, 2.0f, -5.0f)), vec3(0.0f, 0.0f, 1.0f)), 0.0f, 1.0f);
    col += clamp(objectColor(boxes(pos - vec3(6.0f, 2.0f, 20.0f)), vec3(0.0f, 0.0f, 1.0f)), 0.0f, 1.0f);

    col = col * (clamp(dot(sunDir, -normal), 0.0f, 1.0f) * 0.9f + 0.1f);
    col = col + clamp(dot(moonDir, normal), 0.0f, 1.0f) * vec3(0.1f, 0.1f, 0.3f);

    int gHitType = 0;
    float gDist = giraffes(pos, gHitType);
    if(gDist < 0.1f)
    {
        if(gHitType == 0)
        {
            col = vec3(1.0f, 1.0f, 1.0f) * 0.7f;
        }
        else if (gHitType == 2)
        {
            col = vec3(1.0f, 0.4f, 0.2f) * 0.2f;
        }
        else
        {
            pos *= 0.4f;
            float a = clamp(sin(pos.x * 2.0f + pos.y) + cos(pos.x * 3.0f +  pos.y * 5.0f + pos.z * 11.0f) + cos(pos.z * 4.0f + pos.x * 7.0f), 0.0f, 1.0f);
            col = (a) * vec3(0.6f, 0.3f, 0.2f) + (1 - a) * vec3(1.0f, 1.0f, 0.0f);
        }
        col = col * (0.2f +  clamp(dot(sunDir, -normal), 0.0f, 1.0f) * 0.8f);
        col = col + clamp(dot(moonDir, normal), 0.0f, 1.0f) * vec3(0.1f, 0.1f, 0.3f);
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

float march(vec3 pos, vec3 rayDir, out int steps)
{
    float depth = 0.0f;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) 
    {
        steps = i;
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
    float camDist = -50.0f;
    float cameraT = (time + vertTexCoord.y * 4 * sin(PI * 2 * fract(time * 0.1f)));
    vec3 cameraPos = vec3(sin(cameraT) * camDist, 0.0f, cos(cameraT) * camDist);
    vec3 rayTarget = vec3(0.0f, 0.0f, 0.0f);
    vec3 cameraRayDir = normalize(rayTarget - cameraPos);
    vec3 cameraGlobalUp = vec3(0, 1, 0);
    vec3 cameraRight = normalize(cross(cameraRayDir, cameraGlobalUp));
    vec3 cameraUp = cross(cameraRight, cameraRayDir);
    vec2 screenOffset = (vertTexCoord.xy - 0.5f) * screenSize;
    vec3 screenDir = normalize(cameraRight * screenOffset.x + cameraUp * screenOffset.y + cameraRayDir * 1.5f);
    vec3 rayDir = screenDir;

    //cameraPos += sin(time * 3) * cameraRight * 2 + pulse * cameraRayDir * 5;

    vec3 c = vec3(0.0f, 0.0f, 0.0f);
    int steps = 0;
    float dist = march(cameraPos, rayDir, steps);
    

    if(dist < MAX_RAY_LEN)
    {
        vec3 hitPos = cameraPos + rayDir * dist;
        vec3 normal = estimateNormal(hitPos);
        c = sceneColor(hitPos, normal);

        float stepAmount = clamp(steps * 10.0f / MAX_MARCHING_STEPS, 0, 0.2f);
        vec3 rimColor = stepAmount * vec3(0.8f, 0.7f, 0.3f);
        c = mix(c, rimColor, 0.5f - 0.5f * (1 - pulse) *  (1 - pulse));
    }
    else
    {
        float stepAmount = clamp(steps * 20.0f / MAX_MARCHING_STEPS, 0, 1.5f);
        vec3 rimColor = stepAmount * vec3(0.8f, 0.7f, 0.3f) * 0.9f;
        rimColor += (1 - stepAmount) * vec3(0.5f, 0.2f, 0.03f) * 0.8f;
        c = rimColor;
    }

    gl_FragColor = vec4(c, 1.0f);
}