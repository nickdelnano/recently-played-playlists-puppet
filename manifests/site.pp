node default {
  $puppet_bundle_content = @(EOT)
  #!/bin/bash

  export GEM_HOME=vendor/gem
  export GEM_PATH=$GEM_HOME:/opt/puppetlabs/puppet/lib/ruby/gems/2.4.0:$GEM_PATH
  export PATH=/opt/puppetlabs/puppet/bin:$PATH
  
  bundle $*
  | EOT

  file { '/usr/local/bin/puppet-bundle':
    content => $puppet_bundle_content,
    owner   => 'root',
    mode    => '0744',
  }
    include recently_played_playlists
    include recently_played_playlists_parser

  # This username needs to be deployed in .env of recently-played-playlists.
  $mysql_user = 'playlist_user'
  
  # Disable remote MySQL login.
  $override_options = {
    'mysqld' => {
      'bind-address' => '127.0.0.1',
    }
  }
  
  class { '::mysql::server':
    root_password           => '',
    remove_default_accounts => true,
    override_options        => $override_options
  } ->
  
  mysql::db { 'playlists':
    user     => $mysql_user,
    password => '',
    host     => 'localhost',
    grant    => ['SELECT', 'UPDATE', 'INSERT'],
  }
}
