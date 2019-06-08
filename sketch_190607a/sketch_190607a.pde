import moonlander.library.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Moonlander moonlander;
AnnanPallerot annanPallerot;
KiminJaRikunKotostys  kiminJaRikunKotostys;
KuplaKylpy kuplaKylpy;
KuutioKaksi kuutioKaksi;
Water water;

void setup()
{
  //size(640, 360, P3D);
  fullScreen(P3D);
  frameRate(60);
  pixelDensity(displayDensity());
  noCursor(); // Ei voi siirtää ikkunaa jos tää on käytössä
  
  // "random philosophy - more love for all (dark edit)"
  // This track is released under a CC cc-by-nc-sa license.
  moonlander = Moonlander.initWithSoundtrack(this, "morelove_edit_120bpm.wav", 120, 8);
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

void keyPressed()
{
  kiminJaRikunKotostys.keyPressed();
  kuplaKylpy.keyPressed();
  water.keyPressed();
}

void draw()
{
  moonlander.update();
  
  background(0);
  translate(width / 2, height / 2);
  scale(height / 1000f);
  
  double scene = moonlander.getValue("scene");
  float time = (float)moonlander.getCurrentTime();
  float beat = beatGenerator(time, 120);
  float waterHeight = (float)moonlander.getValue("waterHeight");

  if (scene == 0.0)
  {
    annanPallerot.draw();
  }
  else if (scene == 1.0)
  {
    kiminJaRikunKotostys.draw(time, beat);
  }
  else if (scene == 2.0)
  {
    kuplaKylpy.draw(time, beat);
  }
  else if (scene == 3.0)
  {
    kuutioKaksi.draw(time, beat);
  }
  
  if (waterHeight > 0f)
  {
    water.draw(time, beat, waterHeight);
  }
  
  if (moonlander.getValue("exit") == 1.0)
  {
    exit();
  }
}

// Saw tooth beat ramp
// Returns 1 on beat hit and then linearly falls to 0 before the next beat.
float beatGenerator(float time, float bpm)
{
  float beatInterval = 1f / (bpm / 60f);
  float v = 1f - (time % beatInterval) / beatInterval;
  return v;
}
