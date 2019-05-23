import java.io.*;
import ddf.minim.*;
import java.lang.*;
import processing.video.*;
import cvimage.*;
import org.opencv.core.*;

//Detectores
import org.opencv.objdetect.CascadeClassifier;
import org.opencv.objdetect.Objdetect;

int state;
String name = "";
int inc; 
int col;

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

Bird bird;
ArrayList<Integer> wallPosition = new ArrayList();
ArrayList<Wall> walls = new ArrayList();

PFont font;
PImage iniBg, bg;
AudioPlayer music;
boolean au =false;
PImage audio;
PImage noAudio;
//Musica


void setup() {
  size(1024, 600, P3D);
  font = createFont( "Arial", 20);
  iniBg = loadImage("/data/FlappyCat.png");
  bg = loadImage("/data/background.png");
  background(iniBg);

  cam = new Capture(this, 640, 480);
  cam.start(); 

  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);

  img = new CVImage(cam.width, cam.height);

  faceFile = "haarcascade_frontalface_default.xml";
  face = new CascadeClassifier(dataPath(faceFile));

  fill(255);
  textSize(20);
  col = 255;
  inc = -5;



  try { 
    new File(sketchPath("") + "/data/db_puntuacion.txt").createNewFile();
  } 
  catch (IOException ioe) { 
    System.out.println(ioe);
  }  
  resetGame();

  audio = loadImage("/data/audio.png");
  noAudio = loadImage("/data/noAudio.png");
  music = minim.loadFile("music.mp3", 2048);
}

void generateGravity() {
  strength = in.left.level() * 10;

  if (strength > 1) birdHeigth += gravity;
  else  birdHeigth -= gravity;

  if (birdHeigth >= 250) {
    bird.z = 250;
    birdHeigth = 250;
  } else  if (birdHeigth <= 0) {
    bird.z = 0;
    birdHeigth = 0;
  } else bird.z = (int)birdHeigth;
}

void resetGame() { 
  state = 0;
  name = "";

  score = 0;
  cols = 5;
  rows = 3;   
  wallsDistance = 300;
  terrainSpeed = 2;
  bird = new Bird();
  walls.add(new Wall(cols, rows));
  for (int i = 0; i<walls.size(); i++) wallPosition.add(-wallsDistance*i);

  //VariablesSonido
  if (minim == null) {
    minim = new Minim(this);
    in = minim.getLineIn();
  }

  birdHeigth = 125;
  gravity = 2;
}

void draw() {  
  switch (state) {
  case 0:  
    inicio(); 
    break;
  case 1:  
    run();    
    break;
  default: 
    end();
  }
}

void inicio() {
  background(iniBg);
}

void run() {
  println(mouseX + " , " + mouseY);
  background(bg);
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
      if (colision(i)) break;
    }
    if (wallPosition.get(i) >= height) {
      wallPosition.set(i, 0);
      score++;
      println("Score : " + score);
    }
  }

  dibujaSonidoIcon();
  if (cam.available()) {

    cam.read();

    //Obtiene la imagen de la cámara
    img.copy(cam, 0, 0, cam.width, cam.height, 
      0, 0, img.width, img.height);
    img.copyTo();
    pushMatrix();
    translate(0, 0, -50);
    image(img, 300 , 400, 200,200);
    popMatrix();
    //Imagen de grises
    Mat gris = img.getGrey();

    //Imagen de entrada

    //Detección y pintado de contenedores
    FaceDetect(gris);

    gris.release();
  }
}

void end() {   
  background(0);

  if (state == 3) saving();
  else printTable();

  fill(255); 
  textSize(40);
  text("HAS CONSEGUIDO " + score + " PUNTOS", 230, 70);
  fill(col); 
  textSize(20);
  text("Pulse ENTER para volver a jugar", 360, height/2+155);

  col += inc;
  if (col >= 255 || col <= 5) {
    inc *= -1;
  }
}

void saving() {
  fill(255);
  text("Escribe tu nombre:", 420, height/2-40);    
  fill(100); 
  stroke(255);
  rect(width/2-150, height/2-20, 300, 40);
  fill(255);
  text(name, width/2-140, height/2+8);
}

void dibujaSonidoIcon() {
  pushMatrix();
  if (au) {
    image(audio, 670 , 590, 50,50);
  } else {
    image(noAudio, 670 , 590, 50,50);
  }
  popMatrix();
}

void dibujaCarretera() {
  noStroke();
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
    if (bird.z < inicioHuecoZ || bird.z > finHuecoZ) {
      return true;
    } else {
      return false;
    }
  } else return false;
}

boolean colision(int muro) {
  if (colisionX(muro) || colisionZ(muro)) {
    state = 2;
    wallsDistance = 300;
    walls.clear();
    wallPosition.clear();
    return true;
  } else {
    return false;
  }
}

void savelog() {
  if (name != "") {
    try {
      FileWriter fw = new FileWriter(new File(sketchPath("") + "/data/db_puntuacion.txt"), true);
      fw.write(name + "," + score + ";");
      fw.close();
    } 
    catch (IOException ioe) {
      System.out.print(ioe);
    }
  }
  resetGame();
}

void printTable() {
  fill(100); 
  stroke(255);
  rect(width/2-130, height/2+170, 260, 40);
  fill(255); 
  textSize(20); 
  noStroke();
  text("GUARDAR PUNTUACION", width/2-115, height/2+198);

  try {
    String str;    
    BufferedReader br = new BufferedReader(new FileReader(new File(sketchPath("") + "/data/db_puntuacion.txt")));    
    if ((str = br.readLine()) != null) {
      String[][] auxArray = pickBests(str.split(";"));
      fill(255); 
      textSize(25);
      text("RANKING", 460, 115);

      noFill(); 
      stroke(255); 
      textSize(20);
      for (int i=0; i<auxArray.length && auxArray[i][0] != null; i++) {
        rect(width/2-250, 130+i*50, 250, 40);
        text(auxArray[i][0], width/2-230, 160+i*50);
        rect(width/2, 130+i*50, 250, 40);
        text(auxArray[i][1], width/2+110, 160+i*50);
      }
    }
    br.close();
  } 
  catch (IOException ioe) {
    System.out.println(ioe);
  }
}

String[][] pickBests(String[] str) {
  String[] strRanking = new String[str.length];
  int[] intRanking = new int[str.length];  
  for (int i = 0; i < str.length; i++) {
    strRanking[i] = str[i].split(",")[0];
    intRanking[i] = Integer.parseInt(str[i].split(",")[1]);
  }

  int intTemp;
  String strTemp;  
  for (int i = 1; i < str.length; i++) {
    for (int j = i; j > 0; j--) {
      if (intRanking[j] > intRanking[j-1]) {
        intTemp = intRanking[j];
        strTemp = strRanking[j];
        intRanking[j] = intRanking[j-1];
        strRanking[j] = strRanking[j-1];
        intRanking[j-1] = intTemp;
        strRanking[j-1] = strTemp;
      }
    }
  }

  String[][] ranking = new String[5][2];
  for (int i = 0; i < str.length && i<5; i++) {
    ranking[i][0] = strRanking[i];
    ranking[i][1] = Integer.toString(intRanking[i]);
  }

  return ranking;
}

void mouseClicked() {  
  if (state == 0) state = 1; 
  if(state == 1){
  if(mouseX >=width-144 &&mouseX <=width){
    if(mouseY >= height-90 &&  mouseY<= height){
      if(music.isPlaying()){
         music.pause();
      }else{
        music.loop();
      }
      au = !au;
    }
  }
  }
  if (state == 2) {
    if (mouseX >= width/2-130 && mouseX <= width/2+130) 
      if (mouseY >= height/2+170 && mouseY <= height/2+210)
        state = 3;
  }
}

void keyPressed() {
  if (state == 3) {
    if ((key >= 65 && key <= 90) || (key >= 97 && key <= 122))
      if (name.length() <= 10) name += key;
  }
  switch (keyCode) {
  case DELETE: 
    state=2; 
    break;
  case ENTER: 
    if (state > 1) savelog(); 
    break;
  case UP: 
    bird.z += 10; 
    break;
  case DOWN: 
    if (bird.z > 0) bird.z -= 10; 
    break;
  case LEFT: 
    bird.x -= bird.speed; 
    break;
  case RIGHT: 
    bird.x += bird.speed; 
    break;
  case 8: 
    if (state == 3 && name.length() >= 1) name = name.substring(0, name.length()-1);
  }
}

void FaceDetect(Mat grey) {
  MatOfRect faces = new MatOfRect();
  face.detectMultiScale(grey, faces, 1.15, 3, Objdetect.CASCADE_SCALE_IMAGE, new Size(60, 60), new Size(200, 200));
  Rect [] facesArr = faces.toArray();

  //Dibuja contenedores
  noFill();
  stroke(255, 0, 0);
  strokeWeight(4);
  float mov = 0;
  for (Rect r : facesArr) {  
    mov = map(r.x+r.width/2., 0, 640, 5, -5);
    break;
  }
  bird.x=(int)(bird.x + mov);

  faces.release();
}
