class boattr::params {
  $basename        = 'boattr'
  $description     = 'boattr foo bar'
  $boattr_repo     = 'git://github.com/galp/boattr.git'
  $board           = 'BeagleBoneBlack'
  $devel           = false
  $domain          = 'btr'
  $data_dir        = '/data'
  $data_dev        = undef
  $data_fs_type    = 'ext4'
  $lan_subnet      = '192.168.8'
  $lan_ip          = "${lan_subnet}.1"
  $lan_iface       = 'br0'
  $lan_gw          = undef
  $lan_dns         = '127.0.0.1'
  $wan_iface       = 'phone0'
  $wired_iface     = 'eth0'
  $usb_iface       = 'usb0'
  $db_dir          = "${data_dir}/couchdb"
  $db_host         = 'localhost'
  $boattr_dir      = "/root/${basename}"
  $boattr_run      = 'boat'
  $wifi_iface      = 'wlan0'
  $wifi_ssid       = $basename
  $wifi_mac        = undef
  $wpa_psk         = 'c509d57e399416e0c5203a5023c65ad516bb4167632a8a24ba05c9e66b28ae09' # create with wpa_passphrase command
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
  $bin_dir         = '/usr/sbin'
  $masq_script     = 'masq.sh'
  $dhcp_auth       = undef
  $with_tor        = true
  $netdev_mac_list = undef
}
