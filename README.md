#boattr 
Some sort of project to manage off-grid systems

More details [here](http://ag.kiben.net/blog/2014/06/21/boattr/)


#installation


apt-get install puppet git

puppet module install puppetlabs/apt
puppet module install puppetlabs/ntp
puppet module install puppetlabs/vcsrepo ?????

``` bash
cd /root/
git clone git://github.com/galp/boattr.git
cd boattr
puppet apply --modulepath="/root/boattr/provision/modules/:/etc/puppet/modules/"  --verbose  provision/default.pp
```
