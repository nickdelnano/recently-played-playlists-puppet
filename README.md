# How I set this up
I somewhat followed https://www.digitalocean.com/community/tutorials/how-to-set-up-a-masterless-puppet-environment-on-ubuntu-14-04 for this.

# To install:
```
## Install Git and Puppet

wget -O /tmp/puppetlabs.deb http://apt.puppetlabs.com/puppet-release-bionic.deb
dpkg -i /tmp/puppetlabs.deb
apt-get update
apt-get -y install git-core puppet

# Clone the 'puppet' repo
cd /etc
mv puppet/ puppet-bak
git clone git@github.com:ndelnano/playlist-maker-puppet.git puppet

# Run Puppet initially to set up the auto-deploy mechanism
puppet apply /etc/puppet/manifests/site.pp
```


puppet module install camptocamp-systemd --version 2.1.0
