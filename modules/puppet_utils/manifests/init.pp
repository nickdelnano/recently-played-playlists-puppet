class puppet_utils {
  file { '/usr/local/bin/puppet-bundle':
    source  => 'puppet:///modules/puppet_utils/puppet-bundle',
    owner   => 'root',
    mode    => '0744',
  }
}
