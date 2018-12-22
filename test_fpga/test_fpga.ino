#include <SPI.h>

enum {
  CMD_NOP = 0x00,
  CMD_READ = 0x01,
  CMD_WRITE = 0x02,
  CMD_READWRITE = 0x03
};

const int slaveSelectPin = 3;

void setup() {
  Serial.begin(38400);
  pinMode(slaveSelectPin, OUTPUT);
  pinMode(12, INPUT);
  pinMode(13, OUTPUT);
  
  SPI.begin();
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));
  
}

void loop() {
//  writeCMD(CMD_READ, 0b01110110);
//  delay(1000);
  for(int i = 0; i < 0xFF; i++) {
    Serial.println(writeCMD(CMD_READWRITE, i), BIN);
    //delay(1000);
  }
}

uint8_t writeCMD(uint8_t cmd, uint8_t data) {
  uint8_t dataOut = 0;
  // take the SS pin low to select the chip:
  digitalWrite(slaveSelectPin, LOW);
  //  send in the CMD and data via SPI:
  SPI.transfer(cmd);
  dataOut = SPI.transfer(data);
  // take the SS pin high to de-select the chip:
  digitalWrite(slaveSelectPin, HIGH);
  return dataOut;
}

