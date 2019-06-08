#define PROCESSING_TEXTURE_SHADER

uniform float time;
uniform float beat;

varying vec4 vertTexCoord;

void main()
{
	float f = fract(time*0.1f);
	
	
	
	
	gl_FragColor = vec4(vertTexCoord.x, f, beat, 1.0f);
}
