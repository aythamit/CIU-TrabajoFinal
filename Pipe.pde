class Pipe {
  int x;
  int y;
  int z;
  
  PShape modelPipe = loadShape("./data/pipe.obj");
  color colorPipe;
  
  int sides= 20;
  float angle = 360 / sides;
  float halfHeight = 50;
  int radius = 50;

  
  Pipe (int xI, int yI, int zI){
   x = xI;
   y =yI;
   z = zI;
   colorPipe = color(0,255,0);
  }
  
  void display(int yS){
    //pushMatrix();    
    modelPipe.setStroke(color(0, 0, 255)); // Color borde
    modelPipe.setFill(colorPipe); // Color pipe
    stroke(255);
    fill(colorPipe);
    translate(0, 0, -radius*2); 
    // Empieza en posicion
    //shape(modelPipe);
    crearPipe();
    //popMatrix();
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
