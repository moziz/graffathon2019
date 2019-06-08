class KuutioKaksi
{
  
  
  
  public void setup() {
    // fullScreen(P3D);
    // background(#F8F8FF);  // Ghost white (248,248,255)
    // lights();
  }
  
  public void draw(float t) {
    // noStroke();
    pushMatrix();
    // translate(width/2, height/2, 0);
    rotateY(1.25 * (t / 10));
    rotateX(-0.4);
    box(height);
    popMatrix();
  }
}
