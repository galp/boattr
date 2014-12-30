node default {
  $ip = '192.168.8.99'
  class { 'ntp': iburst_enable => true }
  class { 'boattr': lan_ip => $ip}
  class { 'boattr::interfaces' : lan_ip => $ip } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }
  class { 'boattr::dashing': }
  class { 'boattr::packages':  devel => true }

}
node brain00 inherits default {
  $ssid      = 'boat'
}

node boattr {
  $ip         = "192.168.8.137"

  class { 'ntp': iburst_enable => true }
  class { 'boattr': lan_ip => $ip}
  class { 'boattr::interfaces': lan_ip => $ip, wired_iface => 'eth1' } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }
  class { 'boattr::dashing': }
  class { 'boattr::packages':  devel => true }
}
