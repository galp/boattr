import smbus
import time

bus = smbus.SMBus(1)

results8 = []
results10 = []

bus.write_byte(0x28, 0x01)
time.sleep(0.1)
results8 = bus.read_i2c_block_data(0x28, 0x01, 0x0A)
print results8

bus.write_byte(0x28, 0x00)
time.sleep(0.1)
results10 = bus.read_i2c_block_data(0x28, 0x00, 0x14)
print results10
