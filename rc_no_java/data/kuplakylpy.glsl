#version 150
#define PROCESSING_TEXTURE_SHADER

uniform float time;
uniform float beat;

varying vec4 vertTexCoord;

void main()
{
	vec2 pos = (vertTexCoord - vec4(0.5, 0.5, 0, 0)).xy;
	pos.x *= 16.0/9.0;
	float posLength = length(pos);
	
	float f = fract(time * 0.1);
	
	float coreAsdf = sin(time * 8 + atan(pos.y, pos.x) * 3);
	float coreEdge = (0.25 + beat * 0.75) * 0.5  + coreAsdf * 0.125;
	
	float stripes = cos((posLength - coreEdge) * (128 * (1 - posLength)));
	
	if (posLength < coreEdge)
	{
		// Core
		gl_FragColor = vec4(1.0 - beat, f, 1 - beat, 1.0);
	}
	else if (stripes > 0)
	{
		// Stripes
		gl_FragColor = vec4(f, beat, f, 1.0);
	}
	else
	{
		discard;
	}
}
