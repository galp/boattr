import time, sys, subprocess
import datetime
import socket 

beauty_ip = "10.70.60.1"
beauty_port = 2003



def timestamp():
    timestamp = json.dumps(datetime.datetime.now().isoformat()).split('"')[1]
    return timestamp

def getIfBytes(iface):
    raw = (subprocess.Popen(["awk", "/eth0/ { print $2, $10}","/proc/net/dev"], stdout=subprocess.PIPE).communicate()[0]).split()
    rx = raw[0]
    tx = raw[1]
    print rx,tx
    return [rx,tx]

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
now = str(time.time())

data=getIfBytes('eth0')
try:
	rxtx= open('/tmp/rxtx').read()
	old_rx = rxtx.strip().split()[0]
	old_tx = rxtx.strip().split()[1]
        print "old"
        print old_rx,old_tx
except IOError:
	
	print "No bw data"
	open('/tmp/rxtx','w').write(" ".join(data))
	sys.exit()
	#write and exit
print data
cur_rx=int(data[0])-int(old_rx)
cur_tx=int(data[1])-int(old_tx)
print cur_rx,cur_tx
#write data to file
open('/tmp/rxtx','w').write('%i %i' % (cur_rx, cur_tx))
print ""
graph  = ".".join(['boat.bw','eth0'])
graph  = "boat.bandwidth.rx"
packet = " ".join([graph, str(cur_rx), now])
print packet
sock.sendto(packet, (beauty_ip,beauty_port))

graph  = "boat.bandwidth.tx"   
packet = " ".join([graph, str(cur_tx), now])

print "%s  : %s C" %('rx', str(cur_rx))
print "%s  : %s C" %('tx', str(cur_tx))
print packet
sock.sendto(packet, (beauty_ip,beauty_port))

time.sleep(60)
    
