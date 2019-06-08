#define PROCESSING_TEXTURE_SHADER

uniform float time;
varying vec4 vertTexCoord;

void main()
{
	float f = fract(time*0.1f);
	gl_FragColor = vec4(vertTexCoord.x, f, f, 1.0f);
}
