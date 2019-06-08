#version 150
#define PROCESSING_TEXTURE_SHADER

uniform float time;
uniform float beat;

varying vec4 vertTexCoord;

void main()
{
	vec2 pos = (vertTexCoord - vec4(0.5, 0.5, 0, 0)).xy;
	pos.x *= 16.0/9.0;
	
	float f = fract(time * 0.1f);
	
	float asdf = sin(time * 8 + atan(pos.y, pos.x) * 3);
	float holer = (0.25 + beat * 0.75) * 0.5  + asdf * 0.125;
	
	if (length(pos) > holer)
	{
		discard;
	}
	else
	{
		gl_FragColor = vec4(1.0 - beat, f, beat, 1.0f);
	}
}
