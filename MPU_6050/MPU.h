#ifndef MPU_H
#define MPU_H

void processAccelData();
void processGyroData();

#include<Wire.h>

long accelX, accelY, accelZ;
float acc_X, acc_Y, acc_Z;

long gyroX, gyroY, gyroZ;
float roll_rate, pitch_rate, yaw_rate;

void setupMPU(){
  Wire.beginTransmission(0b1101000);
  Wire.write(0x6B);
  Wire.write(0b00000000);
  Wire.endTransmission();
  Wire.beginTransmission(0b1101000);
  Wire.write(0x1B);
  Wire.write(0b00000000);
  Wire.endTransmission();
  Wire.beginTransmission(0b1101000);
  Wire.write(0x1C);
  Wire.write(0x00000000);
  Wire.endTransmission();
}

void recordAccelRegisters(){
  Wire.beginTransmission(0b1101000);
  Wire.write(0x3B);
  Wire.endTransmission();
  Wire.requestFrom(0b1101000,6);
  while(Wire.available() < 6);
  accelX = Wire.read() << 8 | Wire.read();
  accelY = Wire.read() << 8 | Wire.read();
  accelZ = Wire.read() << 8 | Wire.read();
  processAccelData();
}

void processAccelData(){
  acc_X = accelX / 16384.0;
  acc_Y = accelY / 16384.0;
  acc_Z = accelZ / 16384.0;
}

void recordGyroRegisters(){
  Wire.beginTransmission(0b1101000);
  Wire.write(0x43);
  Wire.endTransmission();
  Wire.requestFrom(0b1101000, 6);
  while(Wire.available() < 6);
  gyroX = Wire.read() << 8 | Wire.read();
  gyroY = Wire.read() << 8 | Wire.read();
  gyroZ = Wire.read() << 8 | Wire.read();
  processGyroData();
}

void processGyroData(){
  roll_rate = gyroX / 131.0;
  pitch_rate = gyroY / 131.0;
  yaw_rate = gyroZ / 131.0;
}

#endif
