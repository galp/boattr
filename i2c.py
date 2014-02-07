import smbus
import time, os
import datetime
import rrdtool
import socket 
import json
import couchdb
couch = couchdb.Server('http://192.168.8.1:5984/')
#db = couch.create('sensors')
db = couch['sensors']

bus = smbus.SMBus(1)
beauty_ip = "10.70.60.1"
beauty_port = 2003

def timestamp():
    timestamp = json.dumps(datetime.datetime.now().isoformat()).split('"')[1]
    return timestamp

results8 = []
results10 = []
Vcc=5.0
mid=Vcc/2
step=Vcc/256


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
while True:
    now = str(time.time())
    bus.write_byte(0x28, 0x00)
    results10 = bus.read_i2c_block_data(0x28, 0x00, 0x14)
    #print results10
    raw=results10[0]*256+results10[1]
    volts=raw*(Vcc/1024)
    amps = (volts-mid)/0.066
    print raw,volts, amps
    graph  = ".".join(['boat.power','amps'])
    packet = " ".join([graph, str(amps), now])
    print "Current  : %s A" %(str(amps))
    sock.sendto(packet, (beauty_ip,beauty_port))
    doc = {"_id": now , "type" : "current", "raw" : raw, "amps" : amps}
    db.save(doc)

    time.sleep(60)
    
