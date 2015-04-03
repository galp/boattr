node default {
  $phone_mac = unset # set with the tethered phone mac address.
  $wifi_mac  = unser # the mac of the wifi dongle. 

  class { 'boattr::ntp': }
  class { 'boattr::packages':  devel => true } -> class { 'boattr::users': } -> class { 'boattr': } -> class { 'boattr::dashing': } ->  class { 'boattr::udev': phone_mac => $phone_mac, wifi_mac => $wifi_mac }
  class { 'boattr::interfaces' : } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }



}
node brain01 {
  $ip        = '192.168.8.1'
  $ssid      = 'boat'
  $data_dev  = 'c60fd6ce-2764-4713-aaf8-3bafbc7c5a89' # output from blkid 
  $phone_mac = unset # set with the tethered phone mac address.
  $wifi_mac  = unser # the mac of the wifi dongle. 
  class { 'ntp': iburst_enable => true }
  class { 'boattr::packages':  devel => true } -> class { 'boattr::users': } -> class { 'boattr': lan_ip => $ip} -> class { 'boattr::dashing': } ->  class { 'boattr::udev': phone_mac => $phone_mac, wifi_mac => $wifi_mac }
  class { 'boattr::interfaces' : lan_ip => $ip } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': data_dev => $data_dev } -> class { 'boattr::couchdb': }
  
  
}

node brain02 {
  $ip     = '192.168.8.99'
  $lan_gw = '192.168.8.1'
  $data_dev = undef
  class { 'ntp': iburst_enable => true }
  class { 'boattr::packages':  devel => true } -> class { 'boattr::users': } -> class { 'boattr': lan_ip => $ip} -> class { 'boattr::dashing': }
  class { 'boattr::interfaces' : lan_ip => $ip, lan_gw => $lan_gw } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }
  class { 'boattr::storage': data_dev => $data_dev } -> class { 'boattr::couchdb': }

}
node boattr-vagrant {
  $ip          = '192.168.8.200'
  $lan_gw      = '192.168.8.1'
  $wired_iface = 'eth1'
  class { 'ntp': iburst_enable => true }
  class { 'boattr::packages': } -> class { 'boattr::users': devel => 'devel'} -> class { 'boattr': lan_ip => $ip} ->   class { 'boattr::storage':  } -> class { 'boattr::couchdb': } -> class { 'boattr::dashing': }
  class { 'boattr::interfaces': lan_ip => $ip, wired_iface => $wired_iface, lan_gw => $lan_gw } -> class { 'boattr::dnsmasq': } ->   class { 'boattr::ap' : }

  
  
}
