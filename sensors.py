import time, os
import datetime
import rrdtool
import socket 
import json
import couchdb

couch = couchdb.Server('http://192.168.8.1:5984/')
db = couch['sensors']
beauty_ip = "10.70.60.1"
beauty_port = 2003
path = "/sys/bus/w1/devices/"
tempSensor = { 'beagle' : '10-0008029674ee', 'out' : '10-000802964c0d', 'cylinder' : '10-000802961f0d', 'stove' : '10-00080296978d', 'canal' : '28-000004ee99a8' }

i2cBus = smbus.SMBus(1)
#
Vcc=5.0
mid=Vcc/2
step=Vcc/1024

def timestamp():
    timestamp = json.dumps(datetime.datetime.now().isoformat()).split('"')[1]
    return timestamp

def getTemp(sensor,address):
    if os.path.isfile(path+address+"/w1_slave"):
        try:
            raw = open(path+address+"/w1_slave", "r").read()
            if 'YES' in raw:
                current_temp = float(raw.split("t=")[-1])/1000
                data = { sensor : current_temp }
                return data
            else:
                return 'crc_error'
        except IOError:
            print "%s %s is offline" % (sensor,address)

def getADCvalues(address):
    analog10bitValues = []
    bus.write_byte(0x28, 0x00)
    adc = bus.read_i2c_block_data(0x28, 0x00, 0x14)
    pairs = zip(adc[::2], adc[1::2])
    for pair in pairs:
        a,b = pair
        value = a*256+b
        analog10bitValues.append(value)
    return analog10bitValues

def current(raw):
    """convert an int (0-1024) to Amps """
    values= []
    volts=raw*(Vcc/1024)
    amps = (volts-mid)/0.066
    data = { 'raw': raw ,'volts': volts ,'amps': amps}
    return data
    
def toGraphite(category,name,value,timestamp):
    graph  = ".".join(['boat',category,name])
    packet = " ".join([graph, str(value), timestamp])
    sock.sendto(packet, (beauty_ip,beauty_port))

def toCouchdb(time,):
    doc = { "_id": now , "type" : mytype, "source": source, "data": data }
    db.save(doc)


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
while True:
    now = str(time.time())
    for k,v in tempSensor.iteritems():
        temp=getTemp(k,v)
        if 'crc_error' not in temp:
            toGraphite('temp',k,temp,now)
            toCouchDb(couch,)
            #graph  = ".".join(['boat.temp',k])
            #packet = " ".join([graph, temp, now])
            print "%s  : %s C" %(k, str(temp))
            #sock.sendto(packet, (beauty_ip,beauty_port))
            
   time.sleep(60)
   print "----------"

    
