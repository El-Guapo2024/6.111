#include "YDLidar.h" // Include the YDLidar library or add necessary files

// Create an instance of the YDLidar library
YDLidar ydlidar;

void setup() {
  Serial.begin(9600); // Start serial communication with the same baud rate as the LIDAR
  while (!Serial); // Wait for the serial monitor to open

  // Assuming you have a HardwareSerial interface on Arduino, e.g., Serial1
  Serial1.begin(115200); // Begin serial communication with the LIDAR (adjust the serial port if needed)

  // Initialize the LIDAR
  ydlidar.begin(Serial1, 115200); // Pass the hardware serial object and the LIDAR's baud rate
  // check whether the serial interface is opened
  while(!ydlidar.isOpen());
  // Start the LIDAR scanning
  ydlidar.startScan(); // Set to true to force a scan
}


void loop() {
  if(!ydlidar.isOpen())
  {
    Serial.print("Begin") ;
    ydlidar.begin(Serial1,115200); 
    ydlidar.startScan(); 
    while(!ydlidar.isOpen());
  }
  result_t output = ydlidar.waitScanDot();
  if (output == RESULT_OK) { // Wait for a sample package to arrive
    // Retrieve the current scan point
    const scanPoint &point = ydlidar.getCurrentScanPoint();

    // Display the retrieved data
    Serial.print("Angle: ");
    Serial.print(point.angle);
    Serial.print(" | Distance: ");
    Serial.print(point.distance);
    Serial.print(" | Quality: ");
    Serial.print(point.quality);
    Serial.println("1");
  }
  else if ( output == RESULT_TIMEOUT)
  {
    Serial.println("You have timedout") ;
  }
  else if ( output == RESULT_FAIL)
  {
    Serial.println(" Your Code Failed :( ") ;
  }
  else 
  {
    Serial.println(output+"8") ;
    
  }
}



