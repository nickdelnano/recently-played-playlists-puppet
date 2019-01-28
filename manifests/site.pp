node default {
    include recently_played_playlists

# TODO create system user 'ndelnano' and rename it
# TODO Turn off password auth for root and system user
# TODO run a puppet linter on this?
    
# Disable remote MySQL login.
$override_options = {
  'mysqld' => {
    'bind-address' => '127.0.0.1',
  }
}

# This username needs to be deployed in .env of recently-played-playlists.
$mysql_user = 'playlist_user'

# Don't give root or application users a password
# since we are disabling remote login.
class { '::mysql::server':
  root_password           => 'astrongrootpassword',
  remove_default_accounts => true,
  override_options        => $override_options
}

-> mysql::db { 'playlists':
  user     => $mysql_user,
  password => 'astrongpassword',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE', 'INSERT'],
}


/*

# ocaml stuff
package { 'ocaml':
  ensure => installed,
}

# Includes ocamlbuild
package { 'opam':
  ensure => installed,
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

*/

}
