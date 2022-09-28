# Tasmota_Berry
Berry scripts for Tasmota ESP32

TFLuna LiDAR short distance sensor
Setup I2C ports on your ESP32
Connect TFLuna 
1 wire (red) +5V. 
2 wire SDA
3 wire SCL
4 wire (black) GND
5 wire GND. This brings the sensor in I2C mode
6 wire GPIO23. This is the "data ready" signal. The connected port should configured as NONE.

Upload tfluna.be to your ESP32 file system. 
Create or modify "autoexec.be". Add the line load("tfluna.be")

The script reads every second the distance. It checks are the data valid (GPIO23) and the conditions in range (strength). It builds an average on the messured distance until the next teleperiod and send it by MQTT.
