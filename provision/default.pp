node default {
  class { 'ntp': iburst_enable => true }
  class { 'boattr': }
  class { 'boattr::interfaces' :  } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::tor': }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }
  class { 'boattr::dashing': name => 'dash'}
  class { 'boattr::packages':  devel => true }

}

node brain00 inherits default {
  $subnet    = '192.168.8'
  $domain    = 'boat.dev'
  $interface = 'br0'
  $ssid      = 'boat'

}

  
node boattr {
  $basename   = 'boattr'
  $subnet     = '192.168.8'
  $domain     = 'vagrant'
  $ip         = "${subnet}.2"
  $br_iface   = 'br0'
  $wifi_iface = 'wlan0'
  $ssid       = $boattr
  
  
}
