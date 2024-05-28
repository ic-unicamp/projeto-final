void ADXL345_Init(){

    // +- 16g range, full resolution
    ADXL345_REG_WRITE(ADXL345_REG_DATA_FORMAT, XL345_RANGE_16G | XL345_FULL_RESOLUTION);

    // Output Data Rate: 200Hz
    ADXL345_REG_WRITE(ADXL345_REG_BW_RATE, XL345_RATE_200);

    // The DATA_READY bit is not reliable. It is updated at a much higher rate than the Data Rate
    // Use the Activity and Inactivity interrupts as indicators for new data.
    ADXL345_REG_WRITE(ADXL345_REG_THRESH_ACT, 0x04); //activity threshold
    ADXL345_REG_WRITE(ADXL345_REG_THRESH_INACT, 0x02); //inactivity threshold
    ADXL345_REG_WRITE(ADXL345_REG_TIME_INACT, 0x02); //time for inactivity
    ADXL345_REG_WRITE(ADXL345_REG_ACT_INACT_CTL, 0xFF); //Enables AC coupling for thresholds
    ADXL345_REG_WRITE(ADXL345_REG_INT_ENABLE, XL345_ACTIVITY |XL345_INACTIVITY ); //enable interrupts

    // stop measure
    ADXL345_REG_WRITE(ADXL345_REG_POWER_CTL, XL345_STANDBY);

    // start measure
    ADXL345_REG_WRITE(ADXL345_REG_POWER_CTL, XL345_MEASURE);
 }


 
 // ADXL345_REG_MULTI_READ(0x32, (uint8_t *)&szData8, sizeof(szData8));
 void ADXL345_REG_MULTI_READ(uint8_t address, uint8_t values[], uint8_t len){

    // Send reg address (+0x400 to send START signal)
    *I2C0_DATA_CMD = address + 0x400;

    // Send read signal len times
    int i;
    for (i=0;i<len;i++)
        *I2C0_DATA_CMD = 0x100;

    // Read the bytes
    int nth_byte=0;
    while (len){
        if ((*I2C0_RXFLR) > 0){
            values[nth_byte] = *I2C0_DATA_CMD;
            nth_byte++;
            len--;
        }
    }
 }

 void ADXL345_XYZ_Read(int16_t szData16[3]){

    uint8_t szData8[6];
    ADXL345_REG_MULTI_READ(0x32, (uint8_t *)&szData8, sizeof(szData8));

    szData16[0] = (szData8[1] << 8) | szData8[0];
    szData16[1] = (szData8[3] << 8) | szData8[2];
    szData16[2] = (szData8[5] << 8) | szData8[4];
}

void ADXL345_REG_WRITE(uint8_t address, uint8_t value){
    // Send reg address (+0x400 to send START signal)
    *I2C0_DATA_CMD = address + 0x400;

    // Send value
    *I2C0_DATA_CMD = value;
}