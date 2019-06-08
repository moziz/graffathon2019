import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import moonlander.library.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sketch_190607a extends PApplet {










Moonlander moonlander;
AnnanPallerot annanPallerot;
KiminJaRikunKotostys  kiminJaRikunKotostys;
KuplaKylpy kuplaKylpy;
KuutioKaksi kuutioKaksi;
Water water;

public void setup()
{
  //size(640, 360, P3D);
  
  frameRate(60);
  
  noCursor(); // Ei voi siirtää ikkunaa jos tää on käytössä
  
  // "random philosophy - more love for all (dark edit)"
  // This track is released under a CC cc-by-nc-sa license.
  moonlander = Moonlander.initWithSoundtrack(this, "morelove_120bpm.mp3", 120, 8);
  moonlander.start();
  
  annanPallerot = new AnnanPallerot();
  annanPallerot.setup();
  
  kiminJaRikunKotostys = new KiminJaRikunKotostys();
  kiminJaRikunKotostys.setup();
  
  kuplaKylpy = new KuplaKylpy();
  kuplaKylpy.setup();
  
  kuutioKaksi = new KuutioKaksi();
  kuutioKaksi.setup();
  
  water = new Water();
  water.setup();
}

public void keyPressed()
{
  kiminJaRikunKotostys.keyPressed();
  kuplaKylpy.keyPressed();
  water.keyPressed();
}

public void draw()
{
  moonlander.update();
  
  background(0);
  translate(width / 2, height / 2);
  scale(height / 1000f);
  
  double scene = moonlander.getValue("scene");
  float time = (float)moonlander.getCurrentTime();
  float beat = beatGenerator(time, 120);
  float waterHeight = (float)moonlander.getValue("waterHeight");

  if (scene == 0.0f)
  {
    annanPallerot.draw();
  }
  else if (scene == 1.0f)
  {
    kiminJaRikunKotostys.draw(time, beat);
  }
  else if (scene == 2.0f)
  {
    kuplaKylpy.draw(time, beat);
  }
  else if (scene == 3.0f)
  {
    kuutioKaksi.draw(time, beat);
  }
  
  if (waterHeight > 0f)
  {
    water.draw(time, beat, waterHeight);
  }
  
  if (moonlander.getValue("exit") == 1.0f)
  {
    exit();
  }
}

// Saw tooth beat ramp
// Returns 1 on beat hit and then linearly falls to 0 before the next beat.
public float beatGenerator(float time, float bpm)
{
  float beatInterval = 1f / (bpm / 60f);
  float v = 1f - (time % beatInterval) / beatInterval;
  return v;
}
class AnnanPallerot
{
float colorRed;
float colorGreen;
float colorBlue;

float w = 1778 * 0.6f;
float h = 1000 * 0.6f;
float x = 0;
float y = 0;
float xSpeed = 0.05f;
float ySpeed = 0.051f;
int ballCount = 100;

public void setup() {
  
}

public void draw() {
  background(100, 55, 100);
  fill(colorRed, colorGreen, colorBlue);
  noStroke();
  
  //println("w: " + width + " h: " + height);
  //println("x: " + x + " y: " + y);
  
  for(int i = 0; i < ballCount; i++) {
    circle(x * w - w / 2, y * h - h / 2, h * 0.0625f);
  
    x += xSpeed;
    y += ySpeed;
    
    if(x > 1f || x < 0f) {
      xSpeed *= -1;
      resetColors();
    }
    
    if(y > 1f || y < 0f) {
      ySpeed *= -1;
      resetColors();
    }
  }
}

public void resetColors() {
  colorRed = random(255);
  colorGreen = random(255);
  colorBlue = random(255);
}
}
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

public void setup() {
 // size(640, 360, P2D);
  // Shaders files must be in the "data" folder to load correctly
  blur = loadShader("blur.glsl"); 
  stroke(0, 102, 153);
  rectMode(CENTER);
}

public void keyPressed()
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

public void draw(float time, float beat)
{
  float t = millis() / 1000.0f;
  
  //println("time: " + t);
  blur.set("time", time);
  blur.set("pulse", beat);
  blur.set("screenSize", 1.77777f, 1.0f);
  filter(blur);
}

}
class KuplaKylpy
{
PShader kuplaShader;

public void reloadShaders()
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

public void setup()
{
  reloadShaders();
  rectMode(CENTER);
}

public void keyPressed()
{
  if(key == ' ')
  {
    reloadShaders();
  }
}

public void draw(float time, float beat)
{
  kuplaShader.set("time", time);
  kuplaShader.set("beat", beat);
  
  filter(kuplaShader);
}

}
class KuutioKaksi
{
  
  // PShader blur;
  
  float w = 1778 * 0.8f;
  float h = 1000 * 0.8f;
  
  float boxSize = h/1.6f;
  int boxRotation = 1;
  int count = 8;  // 3x3x3
  int countDiv = 2;  // count/3 = 9
  Box[] boxes;
  
  public void setup() {
    // fullScreen(P3D);
    // background(#F8F8FF);  // Ghost white (248,248,255)
    // lights();
    
    randomSeed(0);
    
    // blur = loadShader("blur.glsl");
    
    boxes = new Box[count];
    int dim = countDiv;  // Box dimension count. 3 boxes per dimension
    int i = 0;
    for (int y = 0; y < dim; y++) {
      for (int x = 0; x < dim; x++) {
        for (int z = 0; z < dim; z++) {
          boxes[i++] = new Box(-(w/5)+x*boxSize, (h)+y*boxSize, z*boxSize,
                               boxRotation, boxRotation, boxRotation);
        }
      }
    }
  }
  
  public void draw(float t, float b) {
    // filter(blur);
    
    // noStroke();
    // pushMatrix();
    // translate(w/2, h/2, 0);
    
    rotateX(-0.4f * sin(t));
    rotateY(1.25f * (sin(t) / 7));
    rotateZ(t/6);
    // fill(0, 0, 0);
    // box(h/4.8, h/4.8, h/1.5);
    
    // popMatrix();
    
    for (Box box : boxes) {
      box.update(t, b);
      // box.display();
      fill(box.c);
      box(boxSize);
    }
  }
}

class Box
{
  float x, y, z;
  float xR, yR, zR;
  int c;
  
  // Constructor
  Box(float xOffset,
      float yOffset,
      float zOffset,
      float xRotation,
      float yRotation,
      float zRotation) {
    x = xOffset;
    y = yOffset;
    z = zOffset;
    xR = xRotation;
    yR = yRotation;
    zR = zRotation;
    
    c = color(random(256), random(256), random(256));
  }
  
  // Custom method for updating the variables
  public void update(float t, float b) {
    translate(0, 0, -t*(b/((t-1)%2)));
    // rotateX(0.0001*b/((t-1)%2));
    rotateX(0);
    rotateY(0);
    rotateZ(zR);
    
    if (t > 3 && (t-1)%2 < 0.05f) {
      c = color(random(256), random(256), random(256));
    }
  }
}
class Water
{
PShader waterShader;

public void reloadShaders()
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

public void setup()
{
  reloadShaders();
  rectMode(CENTER);
}

public void keyPressed()
{
  if(key == ' ')
  {
    reloadShaders();
  }
}

public void draw(float time, float beat, float water)
{
  waterShader.set("time", time);
  waterShader.set("beat", beat);
  waterShader.set("water", water);

  filter(waterShader);
}

}
  public void settings() {  fullScreen(P3D);  pixelDensity(displayDensity()); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sketch_190607a" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
