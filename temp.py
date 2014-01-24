import time
import datetime
import rrdtool
import socket 
import json
#import couchdb
#couch = couchdb.Server('http://192.168.8.1:5984/')
#db = couch['sensors']
beauty_ip = "10.70.60.1"
beauty_port = 2003
path = "/sys/bus/w1/devices/"
tempSensor = { 'beagle' : '10-0008029674ee', 'out' : '10-000802964c0d', 'cylinder' : '10-000802961f0d', 'stove' : '10-00080296978d' }


def timestamp():
    timestamp = json.dumps(datetime.datetime.now().isoformat()).split('"')[1]
    return timestamp

def getTemp(sensor,address):
    raw = open(path+address+"/w1_slave", "r").read()
    current_temp = float(raw.split("t=")[-1])/1000
    
    return current_temp

def printTemp():
    pass


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
while True:
    now = str(time.time())
    for k,v in tempSensor.iteritems():
        temp=str(getTemp(k,v))
        graph  = ".".join(['boat.temp',k])
        packet = " ".join([graph, temp, now])
        print "%s  : %s C" %(k, str(temp))
        #print packet
        sock.sendto(packet, (beauty_ip,beauty_port))
        time.sleep(1)
    print "----------"
    #print "Temperature is %s %s degrees" %(str(float(raw.split("t=")[-1])/1000),str(float(raw1.split("t=")[-1])/1000))
    #doc = {"_id": timestamp() , "temp1" : str(float(raw.split("t=")[-1])/1000), "temp2" : str(float(raw1.split("t=")[-1])/1000)}
    #db.save(doc)
    #print doc
    time.sleep(60)
    
