#- I2C driver for TFLuna LiDAR distance sensor
#- wiring -
#- 1 red wire 5V
#- 2 I2C SDA
#- 3 I2C SCL
#- 4 black wire GND
#- 5 GND TFLuna I2C Mode
#- 6 Data ready GPIO 23

class TFLUNA : Driver
 var wire
 var distance
 var strength
 var temperature
 var dists
 var distc

 def init()
  self.wire = tasmota.wire_scan(0x10,58)
  self.dists=0
  self.distc=0  
  if self.wire
   print('TFLuna detected on bus '+str(self.wire.bus))
  end
 end 
 
 def read_distance()
  if gpio.digital_read(23)==0 # Data ready wire 6 
   print('TFLuna not ready')
   return nil 
  end 
  var b=self.wire.read_bytes(0x10,0x00,6)
  self.strength=b.get(2,2)
  self.distance=b.get(0,2)
  self.temperature=real(b.get(4,2))/100
  if self.strength<100 || self.strength>30000
   print('TFLuna bad conditions')  
  else
   self.distc+=1
   self.dists+=self.distance
  end
  return self.distance
 end

 def every_second() 
  if !self.wire return nil end # I2C error
  self.read_distance()
 end

 def web_sensor()
  if !self.wire return nil end # I2C error
  import string
  var msg = string.format(
      "{s}TFLuna Distance: {m}%.0f cm{e}"..
      "{s}TFLuna Strenght: {m}%.0f {e}"..
      "{s}TFLuna Temperatur: {m}%.2f °C{e}", 
      self.distance,self.strength,self.temperature)
  tasmota.web_send_decimal(msg)
 end
 
 def json_append()
  if !self.wire return nil end  # I2C error
  import string
  var distance = int(self.dists/self.distc)
  var msg = string.format(",\"TFLuna\":{\"distance\":%i}",distance)
  tasmota.response_append(msg)
  self.dists=0
  self.distc=0  
 end
  
end


tfluna = TFLUNA()
tasmota.add_driver(tfluna)
 
   