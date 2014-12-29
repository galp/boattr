class boattr::params {
  $basename        = 'boattr'
  $description     = 'boattr foo bar'
  $data_dir        = '/data'
  $data_dev        = '/dev/sdb1'
  $lan_subnet      = '192.168.8'
  $lan_ip          = "${lan_subnet}.2"
  $lan_iface       = 'br0'
  $wan_iface       = 'usb0'
  $db_dir          = "${data_dir}/couchdb"
  $db_host         = 'localhost'
  $boattr_dir      = "/root/${basename}"
  $wifi_iface      = 'wlan0'
  $wifi_ssid       = $basename
  $wifi_password   = 'testing'
  $wifi_channel    = '11'
  $dash_host       = 'localhost'
  $dash_parent_dir = '/root'
  $dash_name       = "${basename}-dash"
  $dash_dir        = "${dash_parent_dir}/${dash_name}"
  $dash_auth       = 'YOUR_AUTH_TOKEN'
  $i2cAdcAddress   = '0x28'
  $i2cBus          = '/dev/i2c-1'
  $graph_host      = '10.70.60.1'
  $firmware_dir    = '/lib/firmware'
  $cape_slots      = '/sys/devices/bone_capemgr.*/slots'

}
