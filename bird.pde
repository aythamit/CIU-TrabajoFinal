class Bird {
  int x;
  int y;
  int z;
  int size = 14*2;
  int speed = 30;
  PShape modelBird = loadShape("./data/gato.obj");
  
  Bird (){
   x = width / 2;
   y = h;
   z = 80;
  }
  
  void display(){
      pushMatrix();
      translate(x, y, z);
      shape(modelBird);
      popMatrix();
  }
  
}
