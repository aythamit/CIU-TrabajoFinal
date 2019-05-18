import ddf.minim.*;
import java.lang.*;
import processing.video.*;
import cvimage.*;
import org.opencv.core.*;

//Detectores
import org.opencv.objdetect.CascadeClassifier;
import org.opencv.objdetect.Objdetect;

Capture cam;
CVImage img;

CascadeClassifier face;
String faceFile;

Minim minim;
AudioInput in;
AudioPlayer groove;

float gravity;
float birdHeigth;
float strength;
int score;

int w = 1024;


int var = 250;

int cols, rows;
int wallsDistance, terrainSpeed;
int yConst = 600;
int zConst = 100;

color backgroundColor = 0x72a8e2;
Bird bird;
ArrayList<Integer> wallPosition = new ArrayList();
ArrayList<Wall> walls = new ArrayList();

boolean lose = true;
PFont font;

void initVariables() {
  score = 0;
  cols = 5;
  rows = 3;   
  wallsDistance = 300;
  terrainSpeed = 2;
  bird = new Bird();
  walls.add(new Wall(cols, rows));
  //walls.add(new Wall(cols,rows));
  for (int i = 0; i<walls.size(); i++) wallPosition.add(-wallsDistance*i);

  //VariablesSonido
  if (minim == null) {
    minim = new Minim(this);
    in = minim.getLineIn();
  }
  birdHeigth = 125;
  gravity = 2;
}

void generateGravity() {
  strength = in.left.level() * 10; 
  float diferencia = strength + gravity;

  if (strength > 1) birdHeigth += gravity;
  else  birdHeigth -= gravity;

  //println("fuerza : " + strength + " Gravedad: " + gravity + " diferencia: " + diferencia +" altura " + y);
  if (birdHeigth >= 250) {
    bird.z = 250;
    birdHeigth = 250;
  } else  if (birdHeigth <= 0) {
    bird.z = 0;
    birdHeigth = 0;
  } else bird.z = (int)birdHeigth;
}

void setup() {
  size(1024, 600, P3D);
  background(backgroundColor);
  font = createFont( "Arial", 20);
  cam = new Capture(this, 640, 480);
  cam.start(); 
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);
  img = new CVImage(cam.width, cam.height);
  faceFile = "haarcascade_frontalface_default.xml";
  face = new CascadeClassifier(dataPath(faceFile));
  initVariables();
} 


void draw() {
  if (lose) noLoop();
  background(backgroundColor);
  lights();
  noFill();
  translate( width/2, height/2);
  rotateX(radians(70));
  //rotateX(PI/3);
  translate( -width/2, -height/2);

  dibujaCarretera();
  generateGravity();
  for (int i = 0; i < walls.size(); i++) {
    pushMatrix();
    walls.get(i).generaMuro(wallPosition.get(i));
    popMatrix();
  }
  bird.display();
  for (int i = 0; i<wallPosition.size(); i++) {
    wallPosition.set(i, wallPosition.get(i) + terrainSpeed);
    if (wallPosition.get(i) >= height - 50 && wallPosition.get(i) < height) {
      //println("COLISION DE " + i);
      if (colision(i)) break;
    }
    if (wallPosition.get(i) >= height) {
      wallPosition.set(i, 0);
      score++;
      println("Score : " + score);
    }
    //delay(500);
  }
  if (cam.available()) {

    cam.read();

    //Obtiene la imagen de la cámara
    img.copy(cam, 0, 0, cam.width, cam.height, 
      0, 0, img.width, img.height);
    img.copyTo();

    //Imagen de grises
    Mat gris = img.getGrey();

    //Imagen de entrada

    //Detección y pintado de contenedores
    FaceDetect(gris);

    gris.release();
  }
}

void dibujaCarretera() {
  int alturaCarretera = -50;
  pushMatrix();
  fill(0);
  beginShape();
  vertex(300, -300, alturaCarretera);
  vertex(width-300, -300, alturaCarretera);
  vertex(width-100, height, alturaCarretera);
  vertex(0, height, alturaCarretera);
  endShape(CLOSE);
  popMatrix();
  // lineas blancas

  dibujaLineasCarretera(alturaCarretera);

  int mitad = width / 2;
  pushMatrix();
  fill(255);

  beginShape();
  vertex(mitad-5, var, alturaCarretera+2);
  vertex(mitad+5, var, alturaCarretera+2);
  vertex(mitad+5, var-50, alturaCarretera+2);
  vertex(mitad-5, var-50, alturaCarretera+2);
  endShape(CLOSE);
  popMatrix();
  var+=terrainSpeed;
}

void dibujaLineasCarretera(int alturaCarretera) {
  int mitad = width / 2;
  fill(255);
  for (int i = 0; i< 4; i++ ) {
    pushMatrix();
    beginShape();
    vertex(mitad-5, var+200*i, alturaCarretera+2);
    vertex(mitad+5, var+200*i, alturaCarretera+2);
    vertex(mitad+5, var+200*i-50, alturaCarretera+2);
    vertex(mitad-5, var+200*i-50, alturaCarretera+2);
    endShape(CLOSE);
    popMatrix();
  }
  var+=terrainSpeed;
  if (var >= 600) var = -200;
}

boolean colisionX(int muro) {
  if (walls.size() > 0) {
    int inicioHuecoX = 300 + (walls.get(muro).xWindow-1)*100 - 50;
    int finHuecoX =  300 + (walls.get(muro).xWindow)*100 - 50;
    //println("X => ["+inicioHuecoX+"] < " + bird.x +" > ["+finHuecoX+"]");
    if (bird.x < inicioHuecoX || bird.x > finHuecoX) {
      return true;
    } else {
      return false;
    }
  } else return false;
}

boolean colisionZ(int muro) {
  if (walls.size() > 0) {
    int inicioHuecoZ = (walls.get(muro).yWindow-1)*100;
    int finHuecoZ =  (walls.get(muro).yWindow)*100 - 50;
    switch(walls.get(muro).yWindow) {
    case 1:
      inicioHuecoZ = 0;
      finHuecoZ = 20;
      break;
    case 2 :
      inicioHuecoZ = 40;
      finHuecoZ = 110;
      break;
    case 3:
      inicioHuecoZ = 140;
      finHuecoZ = 220;
      break;
    }
    //println("Z => ["+inicioHuecoZ+"] < " + bird.z +" > ["+finHuecoZ+"]");
    if (bird.z < inicioHuecoZ || bird.z > finHuecoZ) {
      return true;
    } else {
      return false;
    }
  } else return false;
}
boolean colision(int muro) {
  //
  if (colisionX(muro) || colisionZ(muro)) {
    hasPerdido();
    lose = true;
    reset();
    return true;
  } else {
    return false;
  }
  //println("Pajaro X : " + bird.x + " Muro X : ");
  /*if( (wallPosition >= h && wallPosition < yConst) && (bird.x < size*colVentana || bird.x > size*(colVentana+sizeVentana)) || (bird.z > z) ){
   text("PERDISTE SOCIO" ,w/2, 20);
   noLoop();
   }*/
}

void hasPerdido() {
  String info= "Has perdido";
  textFont(font);
  textAlign(CENTER);
  pushMatrix();
  translate(width/2, 630, 125);
  strokeWeight(6);
  rotateX(radians(-70));
  println("X: " + width/2 + " Y : " + bird.z + " Z: " + bird.y);
  fill(0, 255, 255);
  text(info, 0, 0, 0);
  rotateX(radians(70));
  popMatrix();
}

void reset() {
  //walls.clear();
  //background(backgroundColor);
  lose = true;
  wallsDistance = 300;
  walls.clear();
  wallPosition.clear();
  initVariables();
  /*walls.add(new Wall(cols,rows));
   walls.add(new Wall(cols,rows));
   for(int i = 0; i<walls.size(); i++) wallPosition.add(-wallsDistance*i);*/
}
void mousePressed() {
  if (lose) {
    reset();
    lose=false;
  }
  //noLoop();
}

void mouseReleased() {

  loop();
}
void keyPressed() {
  if (key == 'a') {
    //z++;
    background(0);
  } else if (key == 's') {
    //z--;
    background(0);
  }
  // Z = 90 X = 88
  if ( key == 'z' ) { 
    bird.z-=10;
  } else if ( key == 'x') { 
    bird.z+=10;
  }
  if ( key == CODED) {
    if ( keyCode == UP) { 
      bird.z+=10;
    } else if ( keyCode == DOWN) { 
      if (bird.z > 0)bird.z-=10;
    } else if ( keyCode == LEFT ) { 
      bird.x-=bird.speed;
    } else if ( keyCode == RIGHT) { 
      bird.x+=bird.speed;
    }
  }
}

void FaceDetect(Mat grey)
{
  //Detección de rostros
  MatOfRect faces = new MatOfRect();
  face.detectMultiScale(grey, faces, 1.15, 3, 
    Objdetect.CASCADE_SCALE_IMAGE, 
    new Size(60, 60), new Size(200, 200));
  Rect [] facesArr = faces.toArray();

  //Dibuja contenedores
  noFill();
  stroke(255, 0, 0);
  strokeWeight(4);
  float mov =0;
  for (Rect r : facesArr) {  
    mov = map(r.x+r.width/2., 0, 640, 5, -5);
    break;
  }
  bird.x=(int)(bird.x + mov);


  //Búsqueda de ojos


  faces.release();
}
