import time
import datetime
import socket 

beauty_ip = "10.70.60.1"
beauty_port = 2003



def timestamp():
    timestamp = json.dumps(datetime.datetime.now().isoformat()).split('"')[1]
    return timestamp

def getIfBytes(iface):
    raw = (subprocess.Popen(["awk", "/eth0/ { print $2, $10}","/proc/net/dev"], stdout=subprocess.PIPE).communicate()[0]).split()
    rx = int(raw[0])
    tx = int(raw[1])
    return [rx,tx]

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
now = str(time.time())

data=getIfBytes('eth0')
if '/tmp/rxtx' :
	read it
	cur_rx=data[0]-old_rx
	cur_tx=data[1]-old_tx
#write data to file
graph  = ".".join(['boat.bw','eth0'])
graph  = "boat.bandwidth.rx"
packet = " ".join([graph, cur_rx, now])
print "%s  : %s C" %(k, str(cur_rx))
print packet
sock.sendto(packet, (beauty_ip,beauty_port))

time.sleep(60)
    
