#version 150
#define PROCESSING_TEXTURE_SHADER

const float PI = 3.1415926f;

uniform float time;
uniform float beat;
uniform float water;

varying vec4 vertTexCoord;

float plasma(vec2 pos, float t)
{
	float u_k = 20;
	
	float v = 0.0;
	vec2 c = pos * u_k - u_k/2.0;
	c.x *= 0.7;
	v += sin((c.x+t));
	v += sin((c.y+t)/2.0);
	v += sin((c.x+c.y+t)/2.0);
	c += u_k/2.0 * vec2(sin(t/3.0), cos(t/2.0));
	v += sin(sqrt(c.x*c.x+c.y*c.y+1.0)+t);
	v = v/2.0;
	
	vec3 col = vec3(1, sin(PI*v), cos(PI*v));
	
	return v;
}

float sinPulse(float t)
{
    return sin((t - 0.5f) * PI * 2) * 0.5 + 0.5;
}

void main()
{
	vec2 pos = (vertTexCoord - vec4(0.5, 0.0, 0, 0)).xy;
	pos.x *= 16.0/9.0;
	float posLength = length(pos);

	float surfHeight = (sin(pos.x * 10 + time * 16) * 0.5 + 0.5) * 0.125 * sinPulse(beat) + water + sinPulse(beat + 0.75) * 0.2 - 0.4;
	
	if (pos.y < surfHeight)
	{
		float diff = surfHeight - pos.y;
		float topMult = clamp(diff * 20, 0, 1);
		float plasmaMult = (1 - diff) * (1 - diff) * (1 - diff) * 4;
		float p = plasma(pos * vec2(1, plasmaMult), time * 8);
		float a = sinPulse(-diff * 10 + p) * 0.7 + 0.3;
		vec3 col = vec3(a * 0.3, a * 0.5, a);
		col *= topMult;
		col += clamp((1 - topMult) * (1 - topMult) * vec3(0.6,0.7,0.9), 0, 1);
		gl_FragColor = vec4(col * (1.5 - diff * 2), 1.0);
	}
	else
	{
		discard;
	}
}
