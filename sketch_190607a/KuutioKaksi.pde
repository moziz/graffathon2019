class KuutioKaksi
{
  
  PShader blur;
  
  int unit = 40;
  int count = 27;  // 3x3x3
  BoxModule[] mods;
  
  public void setup() {
    // fullScreen(P3D);
    // background(#F8F8FF);  // Ghost white (248,248,255)
    // lights();
    
    blur = loadShader("blur.glsl");
    
    mods = new BoxModule[count];
    int hei = count / 9;  // Box count for height
    int wid = count / 9;  // Width
    int dep = count / 9;  // Depth
    int index = 0;
    for (int y = 0; y < hei; y++) {
      for (int x = 0; x < wid; x++) {
        for (int z = 0; z < dep; z++) {
          mods[index++] = new BoxModule(x*unit, y*unit, z*unit,
                                      unit/3, unit/3, unit/3,
                                      random(5, 8), unit);
        }
      }
    }
  }
  
  public void draw(float t, float b) {
    filter(blur);
    
    // noStroke();
    // pushMatrix();
    // translate(width/2, height/2, 0);
    
    rotateY(1.25 * (t / 7));
    rotateX(-0.4);
    // box(height);
    
    // popMatrix();
    
    for (BoxModule mod : mods) {
      mod.update();
      mod.display();
    }
  }
}

class BoxModule
{
  int xOffset;
  int yOffset;
  int zOffset;
  float x, y, z;
  int unit;
  int xDirection = 1;
  int yDirection = 1;
  int zDirection = 1;
  float speed; 
  
  // Contructor
  BoxModule(int xOffsetTemp, int yOffsetTemp, int zOffsetTemp, int xTemp, int yTemp, int zTemp, float speedTemp, int tempUnit) {
    xOffset = xOffsetTemp;
    yOffset = yOffsetTemp;
    zOffset = zOffsetTemp;
    x = xTemp;
    y = yTemp;
    z = zTemp;
    speed = speedTemp;
    unit = tempUnit;
  }
  
  // Custom method for updating the variables
  void update() {
    x = x + (speed * xDirection);
    if (x >= unit || x <= 0) {
      xDirection *= -1;
      x = x + (1 * xDirection);
      y = y + (1 * yDirection);
    }
    if (y >= unit || y <= 0) {
      yDirection *= -1;
      y = y + (1 * yDirection);
    }
  }
  
  // Custom method for drawing the object
  void display() {
    // fill(255);
    // ellipse(xOffset + x, yOffset + y, 6, 6);
    
    box(400);
  }
}
