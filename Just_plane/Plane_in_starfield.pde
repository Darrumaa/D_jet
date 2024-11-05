import processing.serial.*;

Star[] stars  = new Star[2500];

Serial port;
String incomingData = "";
float Pitch, Roll, Yaw;

PShape model;
PImage texture;

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
  model.scale(0.12, 0.12, 0.12);
  model.rotateZ(PI);
  model.rotateX(-(PI/5));
}

void draw() {
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
  rotateZ(radians(Yaw));
  rotateY(radians(Roll));  
  rotateX(radians(Pitch));
  shape(model); 
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
        if (angles.length == 3) {
          try {
            Pitch = float(angles[0]);
            Roll = float(angles[1]);
            Yaw = float(angles[2]);
            println("Pitch: " + Pitch + " Roll: " + Roll + " Yaw: " + Yaw);
          } catch (NumberFormatException e) {
            println("Error parsing values: " + e.getMessage());
          }
        } else {
          println("Unexpected data format: " + completeLine);
        }
      }
    }
  } else {
    println("No data received"); 
    
  }
}
