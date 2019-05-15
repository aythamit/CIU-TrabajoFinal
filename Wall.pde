
// https://www.openprocessing.org/sketch/396286/
class Wall{
 
  int sides= 20;
  float angle = 360 / sides;
  float halfHeight = 50;
  int radius = 50;
  int xWindow, yWindow;
  int colsWalls, rowsWalls;
 
  color colorMuro = color(42,142,47);
  Wall(int c, int r){
    colsWalls = c;
    rowsWalls = r;
    randomWindow();
  }
  
  void generaMuro(int ys){
    if(ys == 0) randomWindow();
    translate(300,ys,0);
    fill(colorMuro);
    //stroke(0);
    noStroke();
    for (int i = 1; i <= colsWalls; i++) {
    if (xWindow != i) { 
      // dibujar pipe completa
      for (int  j = 1; j <= rowsWalls; j++) {
        crearPipe();
        translate(0, 0, radius*2);
       }
    } else {
      // dibujar pipe parcial
      for (int  j = 1; j <= rowsWalls; j++) {
      if (yWindow != j) {
        crearPipe();
        translate(0, 0, radius*2);
       }else {
         translate(0, 0, radius*2);
       }
      }
    }
    // volvemos a parte superior
    translate(radius*2, 0, -radius*2*rowsWalls); 
  }
  }
  void randomWindow() {
    xWindow =int(random(1, colsWalls));
    yWindow = int(random(1, rowsWalls));
    xWindow = 3;
  }
  
    void crearPipe() {
  
  // top shape
  beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * radius;
        float y = sin( radians( i * angle ) ) * radius;
        vertex( x, y, -halfHeight );    
    }
    endShape(CLOSE);
    // draw bottom shape
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * radius;
        float y = sin( radians( i * angle ) ) * radius;
        vertex( x, y, halfHeight );    
    }
    endShape(CLOSE);
  //body
  beginShape(TRIANGLE_STRIP);

      for (int i = 0; i < sides + 1; i++) {
          float x = cos( radians( i * angle ) ) * radius;
          float y = sin( radians( i * angle ) ) * radius;
          vertex( x, y, halfHeight);
          vertex( x, y, -halfHeight);  
      }
   endShape(CLOSE); 
   
}
}
