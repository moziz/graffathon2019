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
void setup()
{
  size(1280, 720, P2D);
  pixelDensity(displayDensity());
  noCursor();
  
  moonlander = Moonlander.initWithSoundtrack(this, "tekno_127bpm.mp3", 127, 8);
  moonlander.start();
  
  annanPallerot = new AnnanPallerot();
  annanPallerot.setup();
  kiminJaRikunKotostys = new KiminJaRikunKotostys();
  kiminJaRikunKotostys.setup();
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
  
  annanPallerot.draw();
  kiminJaRikunKotostys.draw();
  fill(100, 100, 100);
  circle(0,0, 500);
}
