node default {

  include puppet_utils
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
