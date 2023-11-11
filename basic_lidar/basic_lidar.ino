#pragma once

#include "v8stdint.h"
#define LIDAR_CMD_STOP                      0x65
#define LIDAR_CMD_SCAN                      0x60
#define LIDAR_CMD_FORCE_SCAN                0x61
#define LIDAR_CMD_RESET                     0x80
#define LIDAR_CMD_FORCE_STOP                0x00
#define LIDAR_CMD_GET_EAI                   0x55
#define LIDAR_CMD_GET_DEVICE_INFO           0x90
#define LIDAR_CMD_GET_DEVICE_HEALTH         0x91
#define LIDAR_CMD_SYNC_BYTE                 0xA5
#define LIDAR_CMDFLAG_HAS_PAYLOAD           0x8000

#define LIDAR_ANS_TYPE_DEVINFO              0x4
#define LIDAR_ANS_TYPE_DEVHEALTH            0x6
#define LIDAR_ANS_SYNC_BYTE1                0xA5
#define LIDAR_ANS_SYNC_BYTE2                0x5A
#define LIDAR_ANS_TYPE_MEASUREMENT          0x81

#define LIDAR_RESP_MEASUREMENT_SYNCBIT        (0x1<<0)
#define LIDAR_RESP_MEASUREMENT_QUALITY_SHIFT  2
#define LIDAR_RESP_MEASUREMENT_CHECKBIT       (0x1<<0)
#define LIDAR_RESP_MEASUREMENT_ANGLE_SHIFT    1
#define LIDAR_RESP_MEASUREMENT_ANGLE_SAMPLE_SHIFT    8


#define LIDAR_CMD_RUN_POSITIVE             0x06
#define LIDAR_CMD_RUN_INVERSION            0x07
#define LIDAR_CMD_SET_AIMSPEED_ADDMIC      0x09
#define LIDAR_CMD_SET_AIMSPEED_DISMIC      0x0A
#define LIDAR_CMD_SET_AIMSPEED_ADD         0x0B
#define LIDAR_CMD_SET_AIMSPEED_DIS         0x0C
#define LIDAR_CMD_GET_AIMSPEED             0x0D
#define LIDAR_CMD_SET_SAMPLING_RATE        0xD0
#define LIDAR_CMD_GET_SAMPLING_RATE        0xD1

#define LIDAR_STATUS_OK                    0x0
#define LIDAR_STATUS_WARNING               0x1
#define LIDAR_STATUS_ERROR                 0x2

#define PackageSampleBytes 2
#define PackageSampleMaxLngth 0x40
#define Node_Default_Quality (10<<2)
#define Node_Sync 1
#define Node_NotSync 2
#define PackagePaidBytes 10
#define PH 0x55AA
#define PH1 0xAA
#define PH2 0x55

#define YDLIDAR_MOTOR_SCTP 3 // The PWM pin for control the speed of YDLIDAR's motor.
#define YDLIDAR_MOTOR_EN 7 // The ENABLE PIN for YDLIDAR's motor
#define DEFAULT_TIMEOUT 500 

//CT定义
typedef enum {
  CT_Normal = 0,
  CT_RingStart  = 1,
  CT_Tail,
} CT;

struct node_info {
  uint8_t sync_flag;
  uint8_t quality;
  uint16_t angle;
  uint16_t distance;
} __attribute__((packed)) ;

//Single packet data header 
struct node_package_head {
  uint16_t  package_Head;
  uint8_t   package_CT;
  uint8_t   nowPackageNum;
  uint16_t  packageFirstSampleAngle;
  uint16_t  packageLastSampleAngle;
  uint16_t  checkSum;
} __attribute__((packed));
//Single point (without signal strength)
struct node_point {
  uint16_t is : 2;
  uint16_t dist : 14;
} __attribute__((packed));
//Single point (with signal strength)
struct node_point_i {
  uint8_t quality;
  uint16_t is : 2;
  uint16_t dist : 14;
} __attribute__((packed));

//Single packet of point cloud data (without signal strength)
struct node_package {
  node_package_head head;
  node_point points[PackageSampleMaxLngth];
} __attribute__((packed));

//Single package point cloud data (with signal strength)
struct node_package_i {
  struct node_package_head head;
  node_point_i points[PackageSampleMaxLngth];
} __attribute__((packed));

struct device_info {
  uint8_t   model;
  uint16_t  firmware_version;
  uint8_t   hardware_version;
  uint8_t   serialnum[16];
} __attribute__((packed)) ;

struct device_health {
  uint8_t   status;
  uint16_t  error_code;
} __attribute__((packed))  ;

struct sampling_rate {
  uint8_t rate;
} __attribute__((packed))  ;

struct scan_frequency {
  uint32_t frequency;
} __attribute__((packed))  ;

struct scan_rotation {
  uint8_t rotation;
} __attribute__((packed))  ;

struct cmd_packet {
  uint8_t syncByte;
  uint8_t cmd_flag;
  uint8_t size;
  uint8_t data;
} __attribute__((packed)) ;

struct lidar_ans_header {
  uint8_t  syncByte1;
  uint8_t  syncByte2;
  uint32_t size: 30;
  uint32_t subType: 2;
  uint8_t  type;
} __attribute__((packed));

struct scanPoint {
  uint8_t quality;
  float 	angle;
  float 	distance;
  bool    startBit;
};


#if defined(_WIN32)
#pragma pack(1)
#endif

HardwareSerial *_bined_serialdev = NULL;
scanPoint point;
int intensity = 0; //Number of signal strength bits (0 means no signal strength, 8 means 8-bit signal strength, 10 means 10-bit signal strength)
uint8_t* packageBuffer = NULL; //receive cache
bool singleChannel = false; //Single pass identification


result_t waitScanDot(uint32_t timeout = DEFAULT_TIMEOUT)
{
    
  int recvPos = 0 ;
  uint32_t startTs = millis(); 
  uint32_t waitTime = 0 ;
  node_info node ;
  node_package* package = (node_package*) packageBuffer;
  node_package_i* package_i = (node_package_i*) packageBuffer ;
  static uint16_t package_Sample_Index = 0 ;
  static float IntervalSampleAngle = 0 ;
  static float IntervalSampleAngle_LastPackage = 0 ;
  static uint16_t FirstSampleAngle = 0 ; 
  static uint16_t LastSampleAngle = 0 ; 
  static uint16_t CheckSum = 0 ;
  
  static uint16_t CheckSumCal = 0 ;
  static uint16_t SampleNumlAndCTCal = 0 ; 
  static uint16_t LastSampleAngelCal = 0 ;
  static bool CheckSumResult = true; 
  static uint16_t Valu8Tou16 = 0 ;

  static uint8_t package_Sample_Num = 0 ; 
  int32_t AngleCorrectForDistance = 0 ;
  static uint8_t package_CT = 0 ;
  int package_recvPos = 0 ;

  if (package_Sample_Index == 0 )
  {
    recvPos = 0 ;

    while((waitTime = millis() - startTs) <= timeout)
    {
      int currentByte = Serial1.read();

      if (currentByte <0 )
        continue;
      Serial.print("Current Byte: ")
      Serial.println(currentByte); 
      switch (recvPos)
      {
        case 0 :
          if (currentByte != PH1)
          {
            continue;
          }
          break;
        case 1 :
          CheckSumCal = PH ;
          if (currentByte != PH2)
          {
            recvPos = 0 ;
            continue; 
          }
          break;
          case 2 : 
            SampleNumlAndCTCal = currentByte;
            if (((currentByte&0x01) != CT_Normal)&&((currentByte & 0x01 ) != CT_RingStart ))
            {
              recvPos = 0 ;
                continue ;
            }
            package_CT = currentByte ;
            break;
          case 3 :
            SampleNumlAndCTCal += (currentByte << LIDAR_RESP_MEASUREMENT_ANGLE_SAMPLE_SHIFT);
            package_Sample_Num = currentByte ; 
            break;
          case 4 :
            if (currentByte & LIDAR_RESP_MEASURpMENT_CHECKBIT)
            {
                  FirstSampleAngle = currentByte ;
            }
            else 
            {
                recvPos= 0;
                continue;
            }
            break;
        case 5:
        FirstSampleAngle += (currentByte << LIDAR_RESP_MEASUREMENT_ANGLE_SAMPLE_SHIFT);
        CheckSumCal ^= FirstSampleAngle;
        FirstSampleAngle = FirstSampleAngle >> 1;
        break;

      case 6:
        if (currentByte & LIDAR_RESP_MEASUREMENT_CHECKBIT) {
          LastSampleAngle = currentByte;
        } else {
          recvPos = 0;
          continue;
        }
        break;

      case 7:
        LastSampleAngle += (currentByte << LIDAR_RESP_MEASUREMENT_ANGLE_SAMPLE_SHIFT);
        LastSampleAngleCal = LastSampleAngle;
        LastSampleAngle = LastSampleAngle >> 1;

        if (package_Sample_Num == 1) {
          IntervalSampleAngle = 0;
        } else {
          if (LastSampleAngle < FirstSampleAngle) {
            if ((FirstSampleAngle > 17280) && (LastSampleAngle < 5760)) {
              IntervalSampleAngle = ((float)(23040 + LastSampleAngle - FirstSampleAngle)) /
                                    (package_Sample_Num - 1);
              IntervalSampleAngle_LastPackage = IntervalSampleAngle;
            } else {
              IntervalSampleAngle = IntervalSampleAngle_LastPackage;
            }
          } else {
            IntervalSampleAngle = ((float)(LastSampleAngle - FirstSampleAngle)) / (package_Sample_Num - 1);
            IntervalSampleAngle_LastPackage = IntervalSampleAngle;
          }
        }
        break;

      case 8:
        CheckSum = currentByte;
        break;
      case 9:
        CheckSum += (currentByte << LIDAR_RESP_MEASUREMENT_ANGLE_SAMPLE_SHIFT);
        break;
      }

      packageBuffer[recvPos++] = currentByte;

      if (recvPos == PackagePaidBytes) {
        package_recvPos = recvPos;
        break;
      }
    }

    if (PackagePaidBytes == recvPos) 
    {
      startTs = millis();
      recvPos = 0;
      int package_sample_sum = intensity ? package_Sample_Num * 3 : package_Sample_Num * 2;

      while ((waitTime = millis() - startTs) <= timeout) 
      {
        int currentByte = _bined_serialdev->read();
        if (currentByte < 0)
          continue;

        printf("%02X ", uint8_t(currentByte));

        //Compute checksum of point cloud portion
        if (intensity)
        {
          if (recvPos % 3 == 0)
            CheckSumCal ^= uint8_t(currentByte);
          else if (recvPos % 3 == 1)
            Valu8Tou16 = currentByte;
          else
          {
            Valu8Tou16 += (currentByte << LIDAR_RESP_MEASUREMENT_ANGLE_SAMPLE_SHIFT);
            CheckSumCal ^= Valu8Tou16;
          }
        }
        else
        {
          if (recvPos % 2 == 0)
            Valu8Tou16 = currentByte;
          else {
            Valu8Tou16 += (currentByte << LIDAR_RESP_MEASUREMENT_ANGLE_SAMPLE_SHIFT);
            CheckSumCal ^= Valu8Tou16;
          }
        }

        packageBuffer[package_recvPos + recvPos] = currentByte;
        recvPos ++;

        if (package_sample_sum == recvPos) {
          package_recvPos += recvPos;
          break;
        }
      }

      if (package_sample_sum != recvPos) {
        return RESULT_FAIL; // RESULT_FAIL
      }
    } else {
      return RESULT_FAIL;
    }

    CheckSumCal ^= SampleNumlAndCTCal;
    CheckSumCal ^= LastSampleAngleCal;

    if (CheckSumCal != CheckSum) {
      printf("CheckSum error cal: %04X cur: %04X\n", CheckSumCal, CheckSum);
      CheckSumResult = false;
    } else {
      CheckSumResult = true;
    }
  }

  if ((package_CT&0x01) == CT_Normal) {
    node.sync_flag = Node_NotSync;
  } else {
    node.sync_flag = Node_Sync;
  }

  if (CheckSumResult)
  {
    //If with signal strength information
    if (intensity)
    {
      node.quality = package_i->points[package_Sample_Index].quality;
      node.distance = package_i->points[package_Sample_Index].dist;
    }
    else
    {
      node.quality = 0;
      node.distance = package->points[package_Sample_Index].dist;
    }

    if (node.distance != 0) {
      AngleCorrectForDistance = (int32_t)((atan(((21.8 * (155.3 - (node.distance))) /
         155.3) / (node.distance))) * 3666.93);
    } else {
      AngleCorrectForDistance = 0;
    }

    float sampleAngle = IntervalSampleAngle * package_Sample_Index;
    if ((FirstSampleAngle + sampleAngle + AngleCorrectForDistance) < 0) {
      node.angle = (((uint16_t)(FirstSampleAngle + sampleAngle + AngleCorrectForDistance +
          23040)) << LIDAR_RESP_MEASUREMENT_ANGLE_SHIFT) + LIDAR_RESP_MEASUREMENT_CHECKBIT;
    } else {
      if ((FirstSampleAngle + sampleAngle + AngleCorrectForDistance) > 23040) {
        node.angle = ((uint16_t)((FirstSampleAngle + sampleAngle + AngleCorrectForDistance -
            23040)) << LIDAR_RESP_MEASUREMENT_ANGLE_SHIFT) + LIDAR_RESP_MEASUREMENT_CHECKBIT;
      } else {
        node.angle = ((uint16_t)((FirstSampleAngle + sampleAngle + AngleCorrectForDistance)) <<
            LIDAR_RESP_MEASUREMENT_ANGLE_SHIFT) + LIDAR_RESP_MEASUREMENT_CHECKBIT;
      }
    }
  } else {
    node.sync_flag = Node_NotSync;
    node.quality = Node_Default_Quality;
    node.angle = LIDAR_RESP_MEASUREMENT_CHECKBIT;
    node.distance = 0;
    package_Sample_Index = 0;
    return RESULT_FAIL;
  }

  point.distance = node.distance;
  point.angle = (node.angle >> LIDAR_RESP_MEASUREMENT_ANGLE_SHIFT) / 64.0f;
  point.quality = (node.quality);
  point.startBit = (node.sync_flag);

  package_Sample_Index ++;
  if (package_Sample_Index >= package_Sample_Num) {
    package_Sample_Index = 0;
  }

  return RESULT_OK;
}




void setup() {

    Serial.begin(9600);  // Start Uart for the monitor 
    Serial1.begin(115200); // Begin Serial for External 


}

void loop(){
    result_t output = waitScanDot(500);

  if (output == RESULT_OK) { // Wait for a sample package to arrive
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
    Serial.println(output) ;
    
  }

}
