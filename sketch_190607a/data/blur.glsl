#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;


uniform float time;
uniform vec2 screenSize;


const int MAX_MARCHING_STEPS = 20;
const float EPSILON = 0.001f;
const float MAX_RAY_LEN = 100.0f;

float sphereSDF(vec3 p, vec3 spherePos, float radius) 
{
    return (length(p - spherePos) - radius) + cos(2.0f + sin(p.x) + cos(5.0f * p.y));
}
/*
mat4 viewMatrix(vec3 camPos, vec3 dir, vec3 globalUp) 
{
	vec3 right = normalize(cross(dir, globalUp));
	vec3 up = cross(right, dir);
	return mat4(
		vec4(right, 0.0),
		vec4(up, 0.0),
		vec4(-dir, 0.0),
		vec4(camPos, 1)
	);
}
*/

float sphere1(vec3 pos)
{
    return sphereSDF(pos, vec3(5 * sin(time) + 1, 0.0f, -2.0f), 2.5f);
}

float sphere2(vec3 pos)
{
    return sphereSDF(pos, vec3(1.0f, 0.0f, 0.0f), 4.0f);
}

float sceneSDF(vec3 p)
{
    float dist1 = sphere1(p);
    float dist2 = sphere2(p); 
    float dist = max(dist2,  dist2 - dist1);
    //dist = min(dist1, dist2);
    return dist;
}

vec3 objectColor(float dist, vec3 col)
{
    return (1-dist) * col;
}

vec3 sceneColor(vec3 pos)
{
    vec3 col1 = objectColor(sphere1(pos), vec3(1.0f, 0.0f, 0.0f));
    vec3 col2 = objectColor(sphere2(pos), vec3(0.0f, 1.0f, 0.0f));
    return clamp(col1, 0.0f, 1.0f) + clamp(col2, 0.0f, 1.0f);
}

vec3 estimateNormal(vec3 p) 
{
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}

float march(vec3 pos, vec3 rayDir)
{
    float depth = 0.0f;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) 
    {
        float dist = sceneSDF(pos + depth * rayDir);
        if (dist < EPSILON)
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
    return MAX_RAY_LEN;
}

void main()
{
    vec3 sunDir = normalize(vec3(sin(time), cos(time), 1.0f));
    float cameraT = time + vertTexCoord.y * 4;
    vec3 cameraPos = vec3(sin(cameraT) * 20.0f, 0.0f, cos(cameraT) * 20.0f);
    vec3 rayTarget = vec3(0.0f, 0.0f, 0.0f);
    vec3 cameraRayDir = normalize(rayTarget - cameraPos);
    vec3 cameraGlobalUp = vec3(0, 1, 0);
    vec3 cameraRight = normalize(cross(cameraRayDir, cameraGlobalUp));
    vec3 cameraUp = cross(cameraRayDir, cameraRight);
    vec2 screenOffset = (vertTexCoord.xy - 0.5f) * screenSize;
    vec3 screenDir = normalize(cameraRight * screenOffset.x + cameraUp * screenOffset.y + cameraRayDir * 1.5f);
    vec3 rayDir = screenDir;
    vec3 c = vec3(0.0f, 0.0f, 0.0f);

    float dist = march(cameraPos, rayDir);

    if(dist < MAX_RAY_LEN)
    {
        vec3 hitPos = cameraPos + rayDir * dist;
        vec3 normal = estimateNormal(hitPos);
        vec3 baseColor = sceneColor(hitPos);
        c = baseColor * clamp(dot(sunDir, -normal), 0.0f, 1.0f) * 0.9f + 0.1f;
    }

    gl_FragColor = vec4(c, 1.0f);
}