node default {
  $ip        = '192.168.8.1'
  $wifi_ssid = 'boattr'
  $wpa_psk   = 'c509d57e399416e0c5203a5023c65ad516bb4167632a8a24ba05c9e66b28ae09'
  $data_dev  = undef
  $phone_mac = undef # set with the tethered phone mac address.
  $wifi_mac  = undef # the mac of the wifi dongle. 
  $with_tor  = true
  
  class { 'boattr::packages':  devel => true } -> class { 'boattr::ntp': } -> class { 'boattr::users': }
  -> class { 'boattr':  lan_ip => $ip, wired_iface => $wired_iface, wifi_ssid => $wifi_ssid, data_dev => $data_dev, with_tor => $with_tor }
  -> class { 'boattr::dashing': } -> class { 'boattr::couchdb': }
  ->  class { 'boattr::udev': phone_mac => $phone_mac, wifi_mac => $wifi_mac }
  class { 'boattr::dnsmasq': }
 



}
node boattr-vagrant {
  $ip          = '192.168.8.200'
  $wifi_ssid   = unset
  $lan_gw      = '192.168.8.1'
  $wired_iface = 'eth1'
  $wan_iface   = $wired_iface
  $with_tor    = unset

  class { 'boattr::packages': }  class { 'boattr::ntp': } -> class { 'boattr::users': devel => 'devel'}
  -> class { 'boattr': lan_ip => $ip, wired_iface => $wired_iface, wifi_ssid => $wifi_ssid, data_dev => $data_dev, with_tor => $with_tor }
  ->  class { 'boattr::dashing': } -> class { 'boattr::couchdb': }
  ->  class { 'boattr::udev': phone_mac => $phone_mac, wifi_mac => $wifi_mac }
  class { 'boattr::dnsmasq': }
}
