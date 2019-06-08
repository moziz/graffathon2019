uniform float time;

void main()
{
    float f = fract(time*0.1f);
    gl_FragColor = vec4(f, f, f, 1.0f);
}