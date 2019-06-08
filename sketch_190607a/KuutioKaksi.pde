class KuutioKaksi
{
  
  PShader blur;
  
  int boxSize = height/3;
  int boxRotation = 90;
  int count = 27;  // 3x3x3
  Box[] boxes;
  
  public void setup() {
    // fullScreen(P3D);
    // background(#F8F8FF);  // Ghost white (248,248,255)
    // lights();
    
    randomSeed(0);
    
    blur = loadShader("blur.glsl");
    
    boxes = new Box[count];
    int dim = count / 9;  // Box dimension count. 3 boxes per dimension
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
    filter(blur);
    
    // noStroke();
    // pushMatrix();
    // translate(width/2, height/2, 0);
    
    // rotateY(1.25 * (t / 7));
    // rotateX(-0.4);
    // box(height);
    
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
    translate(t*sin((b/((t-1)%2))), 0, 0);
    // rotateX(0.0001*b/((t-1)%2));
    rotateX(0);
    rotateY(0);
    rotateZ(zR);
    
  }
}
