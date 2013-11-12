import time
import datetime
import json
import couchdb
couch = couchdb.Server('http://192.168.8.1:5984/')
db = couch['sensors']

beagleTmp = "/sys/bus/w1/devices/10-0008029674ee/w1_slave"
outTmp    = "/sys/bus/w1/devices/10-000802964c0d/w1_slave"
stoveTmp  = "/sys/bus/w1/devices/10-000802961f0d/w1_slave"
def timestamp():
    timestamp = json.dumps(datetime.datetime.now().isoformat()).split('"')[1]
    return timestamp


while True:
    raw = open(temp1, "r").read()
    time.sleep(0.2)
    raw1 = open(temp2, "r").read()
    #print timestamp()


    print "Temperature is %s %s degrees" %(str(float(raw.split("t=")[-1])/1000),str(float(raw1.split("t=")[-1])/1000))
    #doc = {"_id": timestamp() , "temp1" : str(float(raw.split("t=")[-1])/1000), "temp2" : str(float(raw1.split("t=")[-1])/1000)}
    #db.save(doc)
    print doc
    time.sleep(60)
    
