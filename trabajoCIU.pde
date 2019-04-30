import ddf.minim.*;

Minim minim;
AudioInput in;
AudioPlayer groove;

float gravity;
float birdHeigth;
float strength;


int w = 1024;


int cols, rows;
int wallsDistance, terrainSpeed;
int yConst = 600;
int zConst = 100;

color backgroundColor = 0x72a8e2;
Bird bird;
ArrayList<Integer> wallPosition = new ArrayList();
ArrayList<Wall> walls = new ArrayList();

void initVariables(){
  cols = 5;
  rows = 3;
  wallsDistance = 300;
  terrainSpeed = 3;
  bird = new Bird();
  walls.add(new Wall(cols,rows));
  walls.add(new Wall(cols,rows));
  for(int i = 0; i<walls.size(); i++) wallPosition.add(-wallsDistance*i);
  
  //VariablesSonido
  minim = new Minim(this);
  in = minim.getLineIn();
  birdHeigth = 125;
  gravity = 2;
}

void generateGravity(){
    strength = in.left.level() * 10; 
    float diferencia = strength + gravity;
    
    if(strength > 1) birdHeigth += gravity;
    else  birdHeigth -= gravity;
    
    //println("fuerza : " + strength + " Gravedad: " + gravity + " diferencia: " + diferencia +" altura " + y);
  if (birdHeigth >= 250) {
    bird.z = 250;
     birdHeigth = 250;
  }else  if (birdHeigth <= 0) {
    bird.z = 0;
    birdHeigth = 0;
  }
  else bird.z = (int)birdHeigth;
 
}

void setup() {
  size(1024, 600, P3D);
  background(backgroundColor);
  initVariables();
} 


void draw() {
  background(backgroundColor);
  lights();
  noFill();
  translate( width/2, height/2);
  rotateX(PI/3);
  translate( -width/2, -height/2);
  
  bird.display();
  generateGravity();
  for(int i = 0; i < walls.size(); i++){  // 0 - 1 0 -- 150
    pushMatrix();
    walls.get(i).generaMuro(wallPosition.get(i));
    popMatrix();
  }
  
  for(int i = 0; i<wallPosition.size(); i++){
    wallPosition.set(i, wallPosition.get(i) + terrainSpeed);
    if (wallPosition.get(i) >= height){
      wallPosition.set(i, 0);
    }
  //delay(500);
  }
  
  dibujaCarretera();

  //colision();
}

void dibujaCarretera(){
  pushMatrix();
  fill(0);
  beginShape();
  vertex(300,0,0);
  vertex(width-300,0,0);
  vertex(width-100,height,0);
  vertex(0,height, 0);
  endShape(CLOSE);
  popMatrix();
  
}

/*void colision(){
  println("PajaroX : " + bird.x + " terreno : " + (size*colVentana) + "\t ZBird "+ (size*(colVentana+sizeVentana)) + " z = " + z);
  if( (wallPosition >= h && wallPosition < yConst) && (bird.x < size*colVentana || bird.x > size*(colVentana+sizeVentana)) || (bird.z > z) ){
    text("PERDISTE SOCIO" ,w/2, 20);
    noLoop();
  }
}*/

void mousePressed() {
  noLoop();
}

void mouseReleased() {
  loop();
}
void keyPressed() {
  if(key == 'a'){
    //z++;
   background(0);
  }else if (key == 's'){
    //z--;
   background(0);
  }
  // Z = 90 X = 88
     if ( key == 'z' ) { bird.z-=10; }
        else if ( key == 'x') { bird.z+=10; }
      if ( key == CODED) {
        if ( keyCode == UP) { bird.y-=10; } 
        else if ( keyCode == DOWN) { bird.y+=10; }
        else if ( keyCode == LEFT ) { bird.x-=bird.speed; }
        else if ( keyCode == RIGHT) { bird.x+=bird.speed; }
      }
}
