class Bird {
  int x;
  int y;
  int z;
  int size = 14*2;
  int speed = 10;
  PShape modelBird = loadShape("./data/gato.obj");
  
  Bird (){
   x = 500;
   y = height;
   z = 0;
  }
  
  void display(){
      pushMatrix();
      translate(x, y, z);
      shape(modelBird);
      stroke(0);
      fill(255);
      //box(20,30,40);
      popMatrix();
  }
  
}
