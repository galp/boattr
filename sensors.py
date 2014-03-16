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
acs714=0.066
acs709=0.028

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
    sensor=0
    adc_raw={'adc0': [],'adc1': [],'adc2':[],'adc3': [],'adc4': [],'adc5': [],'adc6':[],'adc7': [],'adc8': [],'adc9': [] }
    for reading in range(10):    
        i2cBus.write_byte(0x28, 0x00)
        adc = i2cBus.read_i2c_block_data(0x28, 0x00, 0x14)
        pairs = zip(adc[::2], adc[1::2])
        sensor=0
        for pair in pairs:
            a,b = pair
            value = a*256+b
            adc_raw['adc'+str(sensor)].append(value)
            sensor+=1
    #print adc_raw
    for i in range(10):
        adc=adc_raw['adc'+str(i)]
        adc.remove(max(adc))
        adc.remove(min(adc))
        adc_raw['adc'+str(i)]=sum(adc)/len(adc) 
    return adc_raw

def voltage(raw,name):
    """ get a raw value and convert it to 12v"""
    voltage= raw * 0.015357
    return { 'name': name,'raw': raw ,'volts': voltage }

def current(raw,name,step):
    """convert an int (0-1024) to Amps """
    values= []
    volts=(raw)*(Vcc/1016)
    amps = (volts-mid)/step
    return { 'name': name,'raw': raw ,'volts': volts ,'amps': amps}
    
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

i2c1 = getADCvalues('0x28')
print i2c1

solar = current(i2c1['adc0'],'solar',acs714)
genny = current(i2c1['adc1'],'genny',acs709)
bat1  = voltage(i2c1['adc3'],'batteries')
cat='current'
now = str(time.time())

toGraphite('current',solar['name'],solar['amps'],now)
toCouchdb(cat,solar)
now = str(time.time())
toGraphite('current',genny['name'],genny['amps'],now)
toCouchdb(cat,genny)

now = str(time.time())
toGraphite('volts','batteries',bat1['volts'],now)
toCouchdb('volts',bat1)

now = str(time.time())
temps = get1wireValues(tempSensor)
toCouchdb('temp',temps)
#toGraphite('temp',bat1['name'],bat1['volts'],now)
#print temps



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

    
