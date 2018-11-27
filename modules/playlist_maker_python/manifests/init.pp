class playlist_maker_python {
  package { 'python3-pip':
    ensure => installed,
  }

  package { 'tox':
    require  => Package['python3-pip'],
    ensure   => latest,
    provider => 'pip3',
  }

}
