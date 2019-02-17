class recently_played_playlists {
  $email = 'nickdelnano@gmail.com'

  package { 'python3-pip':
    ensure => installed,
  }

  # To allow cron to send mail.
  package { 'postfix':
    ensure => 'installed',
  }

  package { 'default-libmysqlclient-dev':
    ensure => installed,
  } ->

  package { 'recently-played-playlists':
    require  => Package['python3-pip'],
    ensure   => latest,
    provider => 'pip3',
  } ->

  # Discard stdout so that cron only emails when stderr contains data.
  cron { 'save-played-tracks':
    command => '/usr/local/bin/recently-played-playlists save-played-tracks > /dev/null',
    user    => 'root',
    minute  => 30,
    environment => "MAILTO=$email",
  } ->

  systemd::unit_file { 'playlists_api.service':
   source => "puppet:///modules/recently_played_playlists/playlists_api.service",
  } ~>

  service { 'playlists_api':
    ensure     => 'running',
    enable     => 'true',
    hasrestart => 'true',
    hasstatus  => 'true',
  }
}
