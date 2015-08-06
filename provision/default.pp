hiera_include('classes')
node default {
  class { 'boattr::packages': } -> class { 'boattr::ntp': } -> class { 'boattr::users': }
  -> class { 'boattr': } -> class { 'boattr::dashing': } -> class { 'boattr::couchdb': }
  class { 'boattr::dnsmasq': }
}
