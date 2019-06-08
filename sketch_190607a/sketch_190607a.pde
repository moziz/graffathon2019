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

void setup()
{
  size(640, 360, P2D);
  pixelDensity(displayDensity());
  //noCursor(); // Ei voi siirtää ikkunaa jos tää on käytössä
  
  moonlander = Moonlander.initWithSoundtrack(this, "morelove_120bpm.mp3", 120, 8);
  moonlander.start();
  
  annanPallerot = new AnnanPallerot();
  annanPallerot.setup();
  
  kiminJaRikunKotostys = new KiminJaRikunKotostys();
  kiminJaRikunKotostys.setup();
  
  kuplaKylpy = new KuplaKylpy();
  kuplaKylpy.setup();
}

void keyPressed()
{
  kiminJaRikunKotostys.keyPressed();
}

void draw()
{
  moonlander.update();
  
  background(0);
  translate(width / 2, height / 2);
  scale(height / 1000f);
  
  double scene = moonlander.getValue("scene");
  float beat = (float)moonlander.getValue("beat");
  float time = (float)moonlander.getCurrentTime();
  
  if (scene == 0.0)
  {
    annanPallerot.draw();
  }
  else if (scene == 1.0)
  {
    kiminJaRikunKotostys.draw(time);
  }
  else if (scene == 2.0)
  {
    kuplaKylpy.draw(time);
  }
}
