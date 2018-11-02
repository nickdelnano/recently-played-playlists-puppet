node default {
    include cron_puppet
    
$override_options = {
  'mysqld' => {
    'bind-address' => '127.0.0.1',
  }
}

class { '::mysql::server':
  root_password           => 'strongpassword',
  remove_default_accounts => true,
  override_options        => $override_options
} ->

mysql::db { 'playlists':
  user     => 'playlist-user',
  password => 'strongpassword',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE', 'INSERT'],
} ->

# Use this to set up the initial schema.
# Migrations will be handled by the application
exec { 'clone_playlist_parser_for_schema':
  command => '/usr/bin/git clone git@github.com:ndelnano/playlist-maker-python.git /playlist-maker-python-schema',
  user => root,
  unless => '/bin/ls /playlist-maker-python-schema',
} ->

# Check for an arbitrary table. Easiest thing I can think of.
exec { 'setup_mysql_schema':
  command => '/usr/bin/mysql -uroot -pstrongpassword playlists < /playlist-maker-python-schema/create_tables.sql',
  user => root,
  unless => '/usr/bin/test -f /var/lib/mysql/playlists/songs_played.ibd',
}

}
