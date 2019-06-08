class Water
{
PShader waterShader;

void reloadShaders()
{
  try
  {
    PShader newShader = loadShader("water.glsl");
    if(newShader != null)
    {
      print("reloaded water");
      waterShader = newShader;
    }
  }
  catch (RuntimeException e)
  {
    print("vituixmän watersaheinf lataaminen: " + e);
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

void draw(float time, float beat, float water)
{
  waterShader.set("time", time);
  waterShader.set("beat", beat);
  waterShader.set("water", water);

  filter(waterShader);
}

}
