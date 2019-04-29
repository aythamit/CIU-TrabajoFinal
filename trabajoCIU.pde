
int w = 1024;
int h = 600;

Bird bird;



int cols, rows;



int yConst = 600;
int zConst = 100;

int terrainSpeed = 0;
int wallsDistance = 250;

ArrayList<Wall> walls = new ArrayList();


void setup() {
  
  bird = new Bird();
  size(1024, 600, P3D);
  background(0);
   walls.add(new Wall(2,2));
   walls.add(new Wall(5,3));
  cols = 5;
  rows = 3;
  
} 


void draw() {
  background(0);
  noFill();
  translate( width/2, height/2);
  rotateX(PI/3);
  translate( -width/2, -height/2);
  
  bird.display();
  translate(300,0,0);
  
  for(int i = 0; i < walls.size(); i++){  // 0 - 1 0 -- 150
  if(i == 0) walls.get(i).generaMuro(terrainSpeed - wallsDistance*i);
  else walls.get(i).generaMuro(-wallsDistance*i);
    println("I: " + i + " translateY -> " + (terrainSpeed - wallsDistance*i));
  }
  


  terrainSpeed+=5;
  if (terrainSpeed == yConst){
    for(int i = 0; i < walls.size(); i++){
      walls.get(i).randomWindow();
    }
    terrainSpeed = -200;
  }
  
  //colision();
}

/*void colision(){
  println("PajaroX : " + bird.x + " terreno : " + (size*colVentana) + "\t ZBird "+ (size*(colVentana+sizeVentana)) + " z = " + z);
  if( (terrainSpeed >= h && terrainSpeed < yConst) && (bird.x < size*colVentana || bird.x > size*(colVentana+sizeVentana)) || (bird.z > z) ){
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
     if ( keyCode == 90 ) { bird.z-=10; }
        else if ( keyCode == 88) { bird.z+=10; }
      if ( key == CODED) {
        if ( keyCode == UP) { bird.y-=10; } 
        else if ( keyCode == DOWN) { bird.y+=10; }
        else if ( keyCode == LEFT ) { bird.x-=bird.speed; }
        else if ( keyCode == RIGHT) { bird.x+=bird.speed; }
      }
}

/**
for (int y = rows-1; y > 0 ; y--) {
    for (int x = 0; x < cols; x++) {
     terrainBot[x][y] = terrainBot[x][y-1];
     terrainTop[x][y] = terrainTop[x][y-1];
    }
  }
   
    // Modo Carretera
      for (int x = 0; x < cols; x++) {
        if(x < colVentana || x  > colVentana + sizeVentana){
          terrainBot[x][0] = 0;      
        }else {
          terrainBot[x][0] = z;
        }
      }
    
  for (int y = 0; y < rows; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      stroke(50-(terrainBot[x][y]/2),100,100);
       vertex(x*size, y*size+terrainSpeed,  terrainBot[x][y]+zConst);
       vertex(x*size, (y+1)*size+terrainSpeed, terrainBot[x][y]+zConst);
    }
    endShape();
  }
   

*/
