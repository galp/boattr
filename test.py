import time
import datetime
import rrdtool
#import json
#import couchdb
#couch = couchdb.Server('http://192.168.8.1:5984/')
#db = couch['sensors']
path = "/sys/bus/w1/devices/"
tempSensor = { 'beagle' : '10-0008029674ee', 'out' : '10-000802964c0d', 'cylinder' : '10-000802961f0d', 'stove' : '10-00080296978d' }


def timestamp():
    timestamp = json.dumps(datetime.datetime.now().isoformat()).split('"')[1]
    return timestamp

def getTemp(sensor):
    raw = open(path+sensor+"/w1_slave", "r").read()
    current_temp = float(raw.split("t=")[-1])/1000
    print "%s  : %s C" %(sensor, str(current_temp))
    rrdtool.update("/run/shm/"+sensor+".rrd", "N:%f" % current_temp)
    return raw

def printTemp():
    pass

while True:
    #raw = open(path+beagle+"/w1_slave", "r").read()
    for k in tempSensor.keys():
        address = tempSensor[k]
        getTemp(address)
        time.sleep(2)
    print "----------"
    #print "Temperature is %s %s degrees" %(str(float(raw.split("t=")[-1])/1000),str(float(raw1.split("t=")[-1])/1000))
    #doc = {"_id": timestamp() , "temp1" : str(float(raw.split("t=")[-1])/1000), "temp2" : str(float(raw1.split("t=")[-1])/1000)}
    #db.save(doc)
    #print doc
    #time.sleep(60)
    
