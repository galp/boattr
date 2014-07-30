

node base {
  include users
  include packages
}

node brain00 inherits base {
  $subnet    = '192.168.8'
  $domain    = 'boat.dev'
  $interface = 'br0'
  $ssid      = 'boat'
  

  class { 'dnsmasq': subnet => $subnet, interface => $interface }
  include storage
  include couchdb
  include boattr
}

node brain02  {
  $subnet     = '192.168.8'
  $domain     = 'camp'
  $ip         = "${subnet}.99"
  $br_iface   = 'br0'
  $wifi_iface = 'wlan0'
  $ssid      = $::hostname
  
  class { 'dnsmasq':  subnet => $subnet, interface => $interface }
  class { 'network::ap' :  ssid => $ssid, wifi_iface => $wifi_iface }
  class { 'network::interfaces' :  }
  class { 'couchdb': }
}

