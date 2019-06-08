class AnnanPallerot
{
float colorRed;
float colorGreen;
float colorBlue;

float w = 1778 * 0.6;
float h = 1000 * 0.6;
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
    circle(x * w - w / 2, y * h - h / 2, h * 0.0625);
  
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
