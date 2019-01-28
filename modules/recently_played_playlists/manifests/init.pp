class recently_played_playlists {
  # TODO note about moving .env file in special place

  package { 'python3-pip':
    ensure => installed,
  }

  package { 'recently-played-playlists':
    require  => Package['python3-pip'],
    ensure   => latest,
    provider => 'pip3',
  } ->

  cron { 'save-played-tracks':
    command => '/usr/local/bin/recently-played-playlists save-played-tracks',
    user    => 'root',
    minute  => 30,
  } ->

  systemd::unit_file { 'playlists_api.service':
   source => "puppet:///modules/recently_played_playlists/playlists_api.service",
  } ~>

  service { 'playlists-api':
    ensure     => 'running',
    enable     => 'true',
    hasrestart => 'true',
    hasstatus  => 'true',
    name       => 'playlists-api',
  }
}
