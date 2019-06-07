import moonlander.library.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Moonlander moonlander;

void setup()
{
  size(640,480,P2D);
  
  moonlander = Moonlander.initWithSoundtrack(this, "mysic.wav", 140, 8);
  moonlander.start();
}

void draw()
{
  moonlander.update();
  
  float x = (float)moonlander.getValue("x");
  
  background(0);
  circle(x, 50, 100);
}
