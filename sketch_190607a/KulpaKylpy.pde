class KuplaKylpy
{
PShader kuplaShader;

void reloadShaders()
{
  try
  {
    PShader newShader = loadShader("kuplakylpy.glsl");
    if(newShader != null)
    {
      print("reloaded kuplakylpy");
      kuplaShader = newShader;
    }
  }
  catch (RuntimeException e)
  {
    print("vituixmän kuplashaderin lataaminen: " + e);
  }
}

void setup()
{
  reloadShaders();
  rectMode(CENTER);
}

void keyPressed()
{
  if(key == ' ')
  {
    reloadShaders();
  }
}

void draw(float time, float beat)
{
  kuplaShader.set("time", time);
  kuplaShader.set("beat", beat);
  
  filter(kuplaShader);
}

}
