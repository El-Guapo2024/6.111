#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>
#include <RPLidar.h>
#include <NewPing.h>

//Lidar set up
RPLidar lidar;
#define RPLIDAR_MOTOR 3  // The PWM pin for control the speed of RPLIDAR's motor. \
                         // This pin should connected with the RPLIDAR's MOTOCTRL signal
#define LIDAR_SERIAL Serial2

//IMU set up
#define BNO055_SAMPLERATE_DELAY_MS (10)
Adafruit_BNO055 bno = Adafruit_BNO055(55, 0x28, &Wire);

//Ultrasound set up
#define TRIGGER_PIN 11
#define ECHO_PIN 10
#define MAX_DISTANCE 200
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);
const int NUM_READINGS_SONAR = 20;
unsigned int total = 0;
unsigned int average = 0;

// !!!!   CHANGE THIS VARIABLE TO DECIDE IF USING ULTRASOUND OR LIDAR
#define USING_ULTRASOUND true

// Serial communication with FPGA
#define FPGASerial Serial3

// ------- Other variables --------- //
// Define the interval for sending data (200 milliseconds)
const unsigned long sendDataInterval = 300;
unsigned long lastSendTime = 0;
unsigned long currentTime = millis();

// Define structure of message to send to FPGA
byte dataToSend[6];
byte mesg_init = 0xAA;
byte sensor_status = 0x0F;
byte imu_reading_msb = 0x00;
byte imu_reading_lsb = 0x00;
byte distance_reading_msb = 0x00;
byte distance_reading_lsb = 0x00;

// MISC global variables
int x;
uint8_t cali_system, gyro, accel, mag = 0;
float distance = 0;

unsigned int distance_sonar = 0;

void setup(void) {

  // Set up serial communications
  Serial.begin(115200);

  while (!Serial) delay(10);  // wait for serial port to open!

  Serial.println("Serial with computer is done ...");

  FPGASerial.begin(115200);

  // Initialize BNO055 and make sure it is calibrated
  while (!bno.begin()) {
    Serial.println("Still connecting to IMU");
    delay(10);
  }

  //uint8_t cali_system, gyro, accel, mag = 0;
  bno.getCalibration(&cali_system, &gyro, &accel, &mag);

  while (cali_system != 3) {
    Serial.println("Still calibrating IMU");
    delay(10);
    bno.getCalibration(&cali_system, &gyro, &accel, &mag);
  }

  Serial.println("IMU set up done ...");

  bno.setExtCrystalUse(true);

  if (USING_ULTRASOUND) {
    while (distance_sonar > 20) {
      distance_sonar = sonar.ping_cm();
      total -= average;
      total += distance_sonar;
      average = total / NUM_READINGS_SONAR;
    }
    Serial.println("Sonar set up done ...");
  } else {
    // Initialize LIDAR
    lidar.begin(Serial2);
    pinMode(RPLIDAR_MOTOR, OUTPUT);
    Serial.println("Lidar Set Up done ...");
  }
}

void loop(void) {
  currentTime = millis();

  if (currentTime - lastSendTime >= sendDataInterval) {
    // assigne bytes to send

    dataToSend[0] = mesg_init;
    dataToSend[1] = sensor_status;
    dataToSend[2] = imu_reading_msb;
    dataToSend[3] = imu_reading_lsb;
    dataToSend[4] = distance_reading_msb;
    dataToSend[5] = distance_reading_lsb;

    FPGASerial.write(dataToSend, sizeof(dataToSend));

    // Print data in the format "0xAA 0xBB 0xCC 0xDD 0xEE 0xFF"
    for (int i = 0; i < sizeof(dataToSend); i++) {
      Serial.print("0x");
      if (dataToSend[i] < 0x10) {
        Serial.print("0");  // Add leading zero for single-digit values
      }
      Serial.print(dataToSend[i], HEX);
      if (i < sizeof(dataToSend) - 1) {
        Serial.print(" ");
      }
    }
    Serial.print("Heading: "); Serial.print(x);  Serial.print(" Distance: "); Serial.print(average);
    Serial.println();  // Add a newline to separate readings

    lastSendTime = millis();
    ;
  }

  /* Get new sensor events */

  // IMU sensor data gathering
  bno.getCalibration(&cali_system, &gyro, &accel, &mag);
  if (cali_system == 3) {
    sensors_event_t event;
    bno.getEvent(&event);

    x = int(event.orientation.x);

    imu_reading_msb = (x >> 8) & 0xFF;
    imu_reading_lsb = x & 0xFF;
    sensor_status = 0xBB;

    // Serial.println("IMU data: ");
    // Serial.print(x);
  } else {
    sensor_status = 0xFF;
  }

  if (USING_ULTRASOUND) {
    distance_sonar = sonar.ping_cm();
    if (distance_sonar != 0) {
      total -= average;
      total += distance_sonar;
      average = total / NUM_READINGS_SONAR;
      distance_reading_msb = (average >> 8) & 0xFF;
      distance_reading_lsb = average & 0xFF;
    } else {
        // Ignore reading object probs too far
    }
  } else {
    /* LiDar sensor event handling below */
    if (IS_OK(lidar.waitPoint())) {
      distance = lidar.getCurrentPoint().distance;       //distance value in mm unit
      float angle = lidar.getCurrentPoint().angle;       //anglue value in degree
      bool startBit = lidar.getCurrentPoint().startBit;  //whether this point is belong to a new scan
      byte quality = lidar.getCurrentPoint().quality;    //quality of the current measurement
      //perform data processing here...
      if (startBit == 1) {
        if (angle > 355 || angle < 5) {
        }
        // Serial.print(distance);
        // Serial.print("   mm ");
        // Serial.print(angle);
        // Serial.print(" degree");
        // Serial.print(startBit);
        // Serial.print(" bool");
        // Serial.print(quality);
        // Serial.println(" byte");

        // here cast to byte and add to data sending
        int distance_int = int(distance);
        distance_reading_msb = (distance_int >> 8) & 0xFF;
        distance_reading_lsb = distance_int & 0xFF;
      }

    } else {
      analogWrite(RPLIDAR_MOTOR, 0);  //stop the rplidar motor
      // try to detect RPLIDAR...
      rplidar_response_device_info_t info;
      if (IS_OK(lidar.getDeviceInfo(info, 100))) {
        // detected...
        //Serial.println("Lidar Detected");
        lidar.startScan();

        // start motor rotating at max allowed speed
        analogWrite(RPLIDAR_MOTOR, 255);
        //delay(1000);
      }
    }
  }

  delay(BNO055_SAMPLERATE_DELAY_MS);
}
