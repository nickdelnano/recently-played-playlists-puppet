node default {
    include cron_puppet

# TODO parameterize user 'ndelnano' -- or leave it and change user to like, playlist-user
    
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
exec { 'clone_playlist_maker_for_schema':
  command => '/usr/bin/git clone https://github.com/ndelnano/playlist-maker-python.git /tmp/playlist-maker-python-schema',
  user => root,
  unless => '/bin/ls /tmp/playlist-maker-python-schema',
} ->

# Check for an arbitrary table. Easiest thing I can think of.
exec { 'setup_mysql_schema':
  command => '/usr/bin/mysql -uroot -pstrongpassword playlists < /tmp/playlist-maker-python-schema/create_tables.sql',
  user => root,
  unless => '/usr/bin/test -f /var/lib/mysql/playlists/songs_played.ibd',
}


# ocaml stuff
package { 'ocaml':
  ensure => installed,
}

# Includes ocamlbuild
package { 'opam':
  ensure => installed,
} ->

# TODO change this. Right now it only clones this once.
exec { 'clone_playlist_parser':
  command => '/usr/bin/git clone https://github.com/ndelnano/playlist-parser.git /home/ndelnano/playlist-parser',
  user => ndelnano,
  unless => '/bin/ls /home/ndelnano/playlist-parser',
} ->

# Global opam install bc I don't see other ocaml programs going on this system
exec { 'configure_opam':
  command => '/usr/bin/opam init',
  user => root,
} ->

exec { 'opam_init':
  command => '/bin/sh /root/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true',
  user => root,
}

# One opam package (cohttp) requires m4, and it is apparently not included on Ubuntu 18.04
package { 'm4':
  ensure => installed,
} ->

package { libgmp3-dev:
  ensure => installed,
} ->

exec { 'install_opam_deps':
  command => '/bin/bash /home/ndelnano/playlist-parser/install_deps.sh',
  user => root,
}

}
