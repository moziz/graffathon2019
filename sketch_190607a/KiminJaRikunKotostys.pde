class KiminJaRikunKotostys
{
float colorRed;
float colorGreen;
float colorBlue;

int x = width/2;
int y = height/2;
int xSpeed = 5;
int ySpeed = 5;
int index = 0;


PShader blur;

void setup() {
 // size(640, 360, P2D);
  // Shaders files must be in the "data" folder to load correctly
  blur = loadShader("blur.glsl"); 
  stroke(0, 102, 153);
  rectMode(CENTER);
}

void keyPressed()
{
  if(key == ' ')
  {
    try
    {
      PShader newShader = loadShader("blur.glsl");
      if(newShader != null)
      {
        blur = newShader;
      }
    }
    catch(RuntimeException e)
    {
      print("failed: " + e);
    }
  }
}

void draw() 
{
  
  
  float t = millis() / 1000.0;
  //println("time: " + t);
  blur.set("time", t);
  filter(blur);  
  rect(mouseX-75, mouseY, 150, 150); 
  ellipse(mouseX+75, mouseY, 150, 150);
}

}
