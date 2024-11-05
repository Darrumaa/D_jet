import processing.serial.*;

Star[] stars  = new Star[2500];

Serial port;
String incomingData = "";
float Pitch, Roll, Yaw, button;
float missileScale = 10.0;
float enemyScale = 0.1;
int lastAttackTime = 0;
int attackInterval = 5000; 
boolean attacking = false;
PShape model;
PShape missile;
PShape enemy;
PImage texture;
PImage texture_missile;
PImage skull;
boolean flag = false;
boolean explosion = false;
float explosionScale = 0.1;
float enemyRatio;
float missileRatio;
boolean gameOver = false;
PFont scaryFont;

void setup() {
  size(800, 600, P3D);
  
  for (int i = 0; i < stars.length; i++){
    stars[i] = new Star();
  }
  
  String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++) {
    println("Port " + i + ": " + ports[i]);
  }
  
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 9600);
  
  model = loadShape("plane.obj");
  texture = loadImage("BodyTexture.bmp");
  missile = loadShape("missile.obj");
  enemy = loadShape("Enemy.obj");
  skull = loadImage("skull.png");
  scaryFont = createFont("Nightcore.ttf", 50);
  model.scale(0.12, 0.12, 0.12);
  model.rotateZ(PI);
  model.rotateX(-(PI/1000));
  model.rotateY(PI);
  model.translate(20, 50, 270);
  missile.scale(missileScale);
  missile.translate(0, 50, 0);
  missile.rotateY(-(PI / 2));
  enemy.rotateX(PI / 2);
  enemy.rotateY(PI);
  enemy.scale(enemyScale);
  for (int i = 0; i < missile.getChildCount(); i++){
    PShape part = missile.getChild(i);
    
    part.setFill(color(70, 72, 46, 255));
    part.setStroke(false);
  }
  for (int i = 0; i < enemy.getChildCount(); i++){
    PShape part = enemy.getChild(i);
    
    part.setFill(color(70, 72, 46, 255));
    part.setStroke(false);
  }
}

void draw() {
  if (gameOver) {
    background(color(#999A98));
    fill(0);          
    textSize(32);
    textAlign(CENTER, CENTER);
    image(skull, width / 2, height / 2.7); 
    text("An  enemy  aircraft\nentered  our  air-space  under  your  watch...\n What  are  you  even  worth  Wing-commander  Jimmy?",  width / 2, height / 5);
    textFont(scaryFont);
    text("Game Over!", width / 4, height / 1.5); 
    return;  
  }
  
  background(0);
  directionalLight(255, 255, 255, 0, 0, -1); // White light coming from the front
  pointLight(255, 255, 255, width/2, height/2, 100); // Point light in the center
  ambientLight(100, 100, 100);
  lights();
  translate(width / 2, height / 2); 
  
  for (int i = 0; i < stars.length; i++){
    stars[i].update();
    stars[i].show();
  }
  
  model.setTexture(texture);
  pushMatrix();
  rotateZ(-(radians(Roll)));
  rotateY(radians(Yaw));  
  rotateX(-(radians(Pitch)));
  shape(model); 
  popMatrix();
  
  if (button == 0.0){
    flag = true;
  }
  
  if (flag){
    missileScale *= 0.80;
  }
  
  if (missileScale < 0.1){
    missileScale = 10.0;
    flag = false;
  }
  
  pushMatrix();
  scale(missileScale);
  shape(missile);
  popMatrix();
  
  int currentTime = millis();
  
  if ((currentTime - lastAttackTime) > attackInterval){
    attacking = true;
    lastAttackTime = currentTime;
    attackInterval = int(random(2000, 10000));
  }
  if(attacking){
    attack();
  }
  
  enemyRatio = enemyScale / 49.9;
  missileRatio = missileScale / 9.9;
  
  if (enemyScale < 49.0){
    if((abs(missileRatio - enemyRatio)) < 0.014){
      explosion = true;
      explosionScale = missileScale;
      enemyScale = 0.1;
      missileScale = 0.1;
    }
  }
  else if(enemyScale > 49.0){
    gameOver = true;
  }
  
  println(abs(missileRatio - enemyRatio));
  
  if (explosion){
    createExplosion();
  }
}

void serialEvent(Serial port) {
  String data = port.readString();
  
  if (data != null) {
    incomingData += data;
    
    int newlineIndex = incomingData.indexOf('\n');
    if (newlineIndex > -1) {
  
      String completeLine = incomingData.substring(0, newlineIndex);
      incomingData = incomingData.substring(newlineIndex + 1);
      
      completeLine = trim(completeLine);
      
      if (completeLine.length() > 0) { 
        
        String[] angles = split(completeLine, ",");
        if (angles.length == 4) {
          try {
            Pitch = float(angles[0]);
            Roll = float(angles[1]);
            Yaw = float(angles[2]);
            button = float(angles[3]);
            print("Button: " + button);
            println("Pitch: " + Pitch + " Roll: " + Roll + " Yaw: " + Yaw);
          } catch (NumberFormatException e) {
            println("Error parsing values: " + e.getMessage());
          }
        } else {
          //println("Unexpected data format: " + completeLine);
        }
      }
    }
  } else {
    println("No data received"); 
    
  }
}

void attack(){
  enemyScale *= 1.1;
  pushMatrix();
  scale(enemyScale);
  shape(enemy);
  popMatrix();
  
  if (enemyScale > 50.0){
    enemyScale = 0.1;
    attacking = false;
  }
}

void createExplosion(){
  noStroke();
  fill(255, 150, 0, 200); 
  pushMatrix();
  scale(explosionScale);
  sphere(10);  
  popMatrix();
  float flag = explosionScale;
  
  explosionScale *= 1.2;  
  
  if (explosionScale > (flag + 1.0)) { 
    explosion = false;  
    explosionScale = 0.1; 
  }
}
