node default {
  $ip = '192.168.8.99'
  class { 'ntp': iburst_enable => true }
  class { 'boattr::packages': } ->  class { 'boattr': lan_ip => $ip} -> class { 'boattr::dashing': }
  class { 'boattr::interfaces' : lan_ip => $ip } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }



}
node brain00 {
  $ip = '192.168.8.1'
  $ssid      = 'boat'
  class { 'ntp': iburst_enable => true }
  class { 'boattr': lan_ip => $ip}
  class { 'boattr::interfaces' : lan_ip => $ip } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }
  class { 'boattr::dashing': }
  class { 'boattr::packages':  devel => true }
}

node brain02 {
  $ip     = '192.168.8.99'
  $lan_gw = '192.168.8.1'
  class { 'ntp': iburst_enable => true }
  class { 'boattr::packages':  devel => true } ->  class { 'boattr': lan_ip => $ip} -> class { 'boattr::dashing': }
  class { 'boattr::interfaces' : lan_ip => $ip, lan_gw => $lan_gw } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }

}
node boattr-vagrant {
  $ip         = '192.168.8.200'
  class { 'ntp': iburst_enable => true }

  class { 'boattr::packages':  devel => true } -> class { 'boattr::users': } -> class { 'boattr': lan_ip => $ip} -> class { 'boattr::dashing': }

  class { 'boattr::interfaces': lan_ip => $ip, wired_iface => 'eth1' } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }

  
}
