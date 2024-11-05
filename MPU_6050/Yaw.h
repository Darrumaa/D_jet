#ifndef Yaw_h
#define Yaw_h

class YawCalculator{
  private:
    float yaw;
    float yaw_bias;
    unsigned long previousTime;

   public:
    YawCalculator(float yaw_bias) : yaw(0.0), previousTime(0),  yaw_bias(yaw_bias){}

    float calculateYaw(float yawRate) {
      unsigned long currentTime = millis();
      float elapsedTime =   (currentTime - previousTime)/ 1000.0;

      if (previousTime != 0){
        yaw += (yawRate - yaw_bias) * elapsedTime;
      }

      previousTime = currentTime;

      return yaw;
    }

    void resetYaw(){
      yaw = 0.0;
      previousTime = millis();
    }
};

#endif
