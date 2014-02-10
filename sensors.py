import time, os
import datetime
import rrdtool
import socket 
import json
import couchdb
import smbus
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

def get1wireValues(sensors):
    data = {}
    for k,v in sensors.iteritems():
        if os.path.isfile("/sys/bus/w1/devices/"+v+"/w1_slave"):
            try:
                raw = open(path+v+"/w1_slave", "r").read()
                if 'YES' in raw:
                    current_temp = float(raw.split("t=")[-1])/1000
                    data[k] = current_temp 
            except IOError:
                print "%s %s is offline" % (sensor,address)
    return data
def getADCvalues(address):
    analog10bitValues = []
    i2cBus.write_byte(0x28, 0x00)
    adc = i2cBus.read_i2c_block_data(0x28, 0x00, 0x14)
    pairs = zip(adc[::2], adc[1::2])
    for pair in pairs:
        a,b = pair
        value = a*256+b
        analog10bitValues.append(value)
    return analog10bitValues
def voltage(raw,name):
    """ get a raw value and convert it to 12v"""
    voltage= raw * 0.0146
    return { 'name': name,'raw': raw ,'volts': voltage }

def current(raw,name):
    """convert an int (0-1024) to Amps """
    values= []
    volts=raw*(Vcc/1024)
    amps = (volts-mid)/0.066
    data = { 'name': name,'raw': raw ,'volts': volts ,'amps': amps}
    return data
    
def toGraphite(category,name,value,timestamp):
    graph  = ".".join(['boat',category,name])
    packet = " ".join([graph, str(value), timestamp])
    sock.sendto(packet, (beauty_ip,beauty_port))
    print packet

def toCouchdb(cat,data):
    doc = { "_id": now , "type" : cat, "data": data }
    print doc
    db.save(doc)


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 

now = str(time.time())

adc_raw = getADCvalues('0x28')
solar = current(adc_raw[0],'solar')

genny = current(adc_raw[1],'genny')
bat1  = voltage(adc_raw[2],'batteries')
cat='current'
now = str(time.time())

toGraphite('current',solar['name'],solar['amps'],now)
toCouchdb(cat,solar)
now = str(time.time())
toGraphite('current',genny['name'],genny['amps'],now)
toCouchdb(cat,genny)

now = str(time.time())
toGraphite('volts',bat1['name'],bat1['volts'],now)
toCouchdb('volts',bat1)

now = str(time.time())
temps = get1wireValues(tempSensor)
toCouchdb('temp',temps)
print temps



# while True:
#     now = str(time.time())
#     for k,v in tempSensor.iteritems():
#         temp_data=getTemp(k,v)
#         if 'crc_error' not in data[k]:
#             toGraphite('temp',k,temp,now)

#             print "%s  : %s C" %(k, str(temp))
#         toCouchdb(now,'temp','1wire',data)
#         print ""
#     time.sleep(60)
#     print "----------"

    
