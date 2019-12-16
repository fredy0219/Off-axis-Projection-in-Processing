/*
  -- Off-axis Projection on Processing
  
  This is a off-axis projection practice project.
  Off-axis relate to Depth Screen or Mirror interactive effects.
  Just like see through the screen.
  
  You can use many kinds of interactive sensors,for example Kinect, RealSence, Camera,
  to capture user's eye position.
  
  Wrote by : WEI-YU CHEN
  2019/12/16
*/

// Aspect ratio for the room
// Screen aspect ratio should be same as the room aspect ratio
int room_length_unit = 1;
int aspect_ratio_x = 16;
int aspect_ratio_y = 10; 

PMatrix3D modelview = new PMatrix3D(); 

PVector near_plane_center = new PVector(0,0,-50);

//Point of near plane
PVector pa = new PVector(-aspect_ratio_x,-aspect_ratio_y,near_plane_center.z);
PVector pb = new PVector(aspect_ratio_x,-aspect_ratio_y,near_plane_center.z);
PVector pc = new PVector(-aspect_ratio_x,aspect_ratio_y,near_plane_center.z);
PVector pe = new PVector(0,0,0); //Eye position

int near_dist = 10;
int far_dist = 20000;

void setup(){
  size(800,500,P3D);
  //fullScreen(P3D); // 1280 800
  
  //Change the camera setting, look from 'pe' to 'near_plane_center'.
  camera(pe.x, pe.y, pe.z,
          near_plane_center.x, near_plane_center.y, near_plane_center.z,
          0, 1, 0);
}

void draw(){
  background(0);
  
  //Off_axis Projection
  off_axis(pa, pb, pc, pe, near_dist, far_dist);
  
  //Draw environment
  spotLight(255,255,255,0,0,-80,0,0,-1, PI/2.0, 1);
  draw_room();
  
  //Simulate the eye movement.
  //In this case, you can replace it to Kinect head_point coordinate;
  float circle_range = 5.0;
  pe.x = cos(millis()/20000.0 * TWO_PI) * circle_range;
  pe.y = sin(millis()/20000.0 * TWO_PI) * circle_range;
  
  saveFrame("save/frame_####.png"); 
  
}

void off_axis(PVector _pa, PVector _pb, PVector _pc, PVector _pe, float n, float f){
  
  PVector va, vb, vc = new PVector();
  PVector vr, vu, vn = new PVector();
  
  float l, r, b, t, d;
  PMatrix3D M = new PMatrix3D();
  
  vr = PVector.sub(_pb,_pa);
  vu = PVector.sub(_pc,_pa);
  
  vr.normalize();
  vu.normalize();
  
  vn = vr.cross(vu);
  vn.normalize();
  
  va = PVector.sub(_pa,_pe);
  vb = PVector.sub(_pb,_pe);
  vc = PVector.sub(_pc,_pe);
  
  d = -va.dot(vn);
  
  l = vr.dot(va) * n / d;
  r = vr.dot(vb) * n / d;
  b = vu.dot(va) * n / d;
  t = vu.dot(vc) * n / d;
  
  M.apply(vr.x, vu.x, vn.x, 0,
          vr.y, vu.y, vn.y, 0,
          vr.z, vu.z, vn.z, 0,
          0   , 0   , 0   , 1.0f);
   
  ((PGraphicsOpenGL)g).projection.reset();
  frustum(l, r, b, t, n, f);
  
  ((PGraphicsOpenGL)g).projection.apply(M);
  ((PGraphicsOpenGL)g).projection.translate(-pe.x, pe.y, -pe.z);

}

int room_depth = 100;
float box_rotation_X = 0;
float box_rotation_Y = 0;
void draw_room(){
  noStroke();
  
  //Rotating box
  pushMatrix();
  translate(10,-5,-room_depth+15); // Put the box front of the wall
  //box_rotation_X += 0.01f;
  //box_rotation_Y += 0.01f;
  rotateX(box_rotation_X+=0.01f);
  rotateY(box_rotation_Y+=0.01f);
  box(2);
  popMatrix();
  
  
  //Front Wall
  beginShape();
  vertex(pc.x, pc.y, -room_depth);
  vertex(pb.x, pc.y, -room_depth);
  vertex(pb.x, pb.y, -room_depth);
  vertex(pa.x, pa.y, -room_depth);
  endShape(CLOSE);
  
  //Left wall
  beginShape();
  vertex(pc.x, pc.y, pc.z);
  vertex(pc.x, pc.y, -room_depth);
  vertex(pa.x, pa.y, -room_depth);
  vertex(pa.x, pa.y, pa.z);
  endShape(CLOSE);
  
  //Right wall
  beginShape();
  vertex(pb.x, pc.y, pc.z);
  vertex(pb.x, pc.y, -room_depth);
  vertex(pb.x, pb.y, -room_depth);
  vertex(pb.x, pb.y, pa.z);
  endShape(CLOSE);
  
  //Floor
  beginShape();
  vertex(pc.x, pc.y, pc.z);
  vertex(pc.x, pc.y, -room_depth);
  vertex(pb.x, pc.y, -room_depth);
  vertex(pb.x, pc.y, pc.z);
  endShape(CLOSE);
  
  //Ceiling
  beginShape();
  vertex(pb.x, pa.y, pa.z);
  vertex(pb.x, pa.y, -room_depth);
  vertex(pa.x, pa.y, -room_depth);
  vertex(pa.x, pa.y, pa.z);
  endShape(CLOSE);
  
}