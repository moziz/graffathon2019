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

public void setup() {
  
}

public void draw() {
  background(100, 20, 100);
  fill(colorRed, colorGreen, colorBlue);
  noStroke();
  /*if(index == 5) {
    stop();
  }*/
  for(int i=0; i<=index; i++) {
    circle(x, y, 50);
  }
  x += xSpeed;
  y += ySpeed;
  if(x > width-25 || x < 25) {
    xSpeed *= -1;
    index++;
    resetColors();
  }
  if(y > height-25 || y < 25) {
    ySpeed *= -1;
    index++;
    resetColors();
  }
}

public void resetColors() {
  colorRed = random(255);
  colorGreen = random(255);
  colorBlue = random(255);
}
}
