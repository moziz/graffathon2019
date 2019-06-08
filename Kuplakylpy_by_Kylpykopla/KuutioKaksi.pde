class KuutioKaksi
{
  
  // PShader blur;
  
  float w = 1778 * 0.8;
  float h = 1000 * 0.8;
  
  float boxSize = h/1.6;
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
    
    rotateX(-0.4 * sin(t));
    rotateY(1.25 * (sin(t) / 7));
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
  color c;
  
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
  void update(float t, float b) {
    translate(0, 0, -t*(b/((t-1)%2)));
    // rotateX(0.0001*b/((t-1)%2));
    rotateX(0);
    rotateY(0);
    rotateZ(zR);
    
    if (t > 3 && (t-1)%2 < 0.05) {
      c = color(random(256), random(256), random(256));
    }
  }
}
