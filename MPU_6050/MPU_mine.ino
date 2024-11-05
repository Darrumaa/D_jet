#include <avr/wdt.h>
#include"MPU.h"
#include "KalmanFilter.h"
#include "Yaw.h"
#define Bpin 4

float AccRoll;
float AccPitch;
float kalPitch = 0;
float kalRoll = 0;
float yaw_bias = 0.0;
float angles[4];
int button; 

KalmanFilter kalmanX(0.001, 0.003, 0.03);
KalmanFilter kalmanY(0.001, 0.003, 0.03);


void setup() {
  Serial.begin(9600);
  Wire.begin();
  setupMPU();


  yaw_bias = 0.0;
  int num_samples = 100;
  for (int i = 0; i < num_samples; i++){
    yaw_bias += yaw_rate;
    delay(10);
  }

  yaw_bias /= num_samples;
  wdt_enable(WDTO_8S);
  pinMode(Bpin, INPUT_PULLUP);
}

YawCalculator yawCalculator(yaw_bias);

void loop() {
  button = digitalRead(Bpin);
  recordAccelRegisters();
  recordGyroRegisters();
  AccRoll=atan(acc_Y/sqrt(acc_X*acc_X+acc_Z*acc_Z))*1/(3.142/180);
  AccPitch=-atan(acc_X/sqrt(acc_Y*acc_Y+acc_Z*acc_Z))*1/(3.142/180);
  kalPitch = kalmanY.update(AccPitch, pitch_rate);
  kalRoll = kalmanX.update(AccRoll, roll_rate);
  float yaw = yawCalculator.calculateYaw(yaw_rate);
  angles[0] = kalPitch;
  angles[1] = kalRoll;
  angles[2] = yaw;
  angles[3] = button;
  Serial.print(angles[0]);
  Serial.print(",");
  Serial.print(angles[1]);
  Serial.print(",");
  Serial.print(angles[2]);
  Serial.print(",");
  Serial.println(angles[3]);
  Serial.print("Gyroscope readings: ");
  Serial.print(roll_rate);
  Serial.print(", ");
  Serial.print(pitch_rate);
  Serial.print(", ");
  Serial.println(yaw_rate);
}
