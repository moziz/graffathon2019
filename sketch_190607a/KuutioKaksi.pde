class KuutioKaksi
{
  
  // PShader blur;
  
  float boxSize = height/1.6;
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
          boxes[i++] = new Box(-(width/5)+x*boxSize, (height)+y*boxSize, z*boxSize,
                               boxRotation, boxRotation, boxRotation);
        }
      }
    }
  }
  
  public void draw(float t, float b) {
    // filter(blur);
    
    // noStroke();
    // pushMatrix();
    // translate(width/2, height/2, 0);
    
    rotateX(-0.4 * sin(t));
    rotateY(1.25 * (sin(t) / 7));
    rotateZ(t/6);
    // fill(0, 0, 0);
    // box(height/4.8, height/4.8, height/1.5);
    
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
