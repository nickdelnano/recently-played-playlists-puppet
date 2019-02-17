.PHONY: r10k apply noop

r10k:
		puppet-bundle exec r10k puppetfile install

apply:
		sudo /opt/puppetlabs/bin/puppet apply manifests/site.pp --test

noop:
		sudo /opt/puppetlabs/bin/puppet apply manifests/site.pp --noop --test
