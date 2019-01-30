class recently_played_playlists_parser {
  # TODO: package recently_played_playlists_parser as an opam package and install via opam.
  # For now, fall back to manual instructions in README

  # Install packages that are required by some dependencies of recently_played_playlists_parser
  # One opam package (cohttp) requires m4 and libgmp3-dev.

  package { 'm4':
    ensure => installed,
  }

  package { 'opam':
    ensure => installed,
  }

  package { libgmp3-dev:
    ensure => installed,
  }
}
