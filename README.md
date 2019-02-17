# dlslslnls
talling recently-played-playlists and recently-played-playlists-parser

This documentation was written with Ubuntu 18.04 in mind.

## [Create spotify developer application](https://developer.spotify.com/dashboard/applications).
- Clone [spotify web auth examples](https://github.com/spotify/web-api-auth-examples) and follow instructions in README -- but take note of the following below:
  - Add `http://localhost:8888/callback` as a redirect URI for the new app in spotify developer app dashboard
  - In app.js, set `client_id = YOUR_SECRET`, `client_secret = YOUR_SECRET`, `redirect_uri = http://localhost:8888/callback`
  - Edit permission scopes in app.js: `var scope = 'playlist-modify-public playlist-modify-private user-read-recently-played user-library-read'`
  - Visit `http://localhost:8888` in browser and proceed with login
  - After going through auth flow, collect your `access token` and `refresh token`. Set aside for later. Note: the HTML UI that spotify returns the tokens in is confusing. Triple click to ensure you are selecting and copying the text that runs off of the text box.

## Set up [recently-played-playlists](https://github.com/ndelnano/recently-played-playlists) and [recently-played-playlists-parser](https://github.com/ndelnano/recently-played-playlists-parser).

Do all of the below as `root` user :-)

```

## Install git and puppet

wget -O /tmp/puppetlabs.deb http://apt.puppetlabs.com/puppet-release-bionic.deb
dpkg -i /tmp/puppetlabs.deb
apt-get update
apt-get -y install git-core puppet

# Clone the 'puppet' repo
cd /etc
mv puppet/ puppet-bak
git clone git@github.com:ndelnano/recently-played-playlists-puppet.git puppet

```

### Puppeted installation
The manifest at `/etc/puppet/manifests/site.pp` sets up recently-played-playlists entirely. It is not complete for recently-played-playlists-parser; it only installs the required apt packages. Manual instructions for installing the parser are included.

Edit `$email=''` in modules/recently_played_playlists/manifests/init.pp so that you get emails from cron. The current cron configuration for `recently-played-playlists save-played-tracks > /dev/null` will only send email when stderr has data. You will also want to ensure these emails do not go to your spam folder.

```
# Applying this manifest will do the following:
# - Start MySQL
# - Install packages for recently-played-playlists-parser
# - Install recently-played-playlists, start its HTTP API, add cron for polling Spotify's recently-played endpoint

puppet apply /etc/puppet/manifests/site.pp
```

MySQL is now running with remote login disabled--this is why the users 'root' and 'playlist_user' have an empty password. 

To create the MySQL tables:
```
cd
wget https://raw.githubusercontent.com/ndelnano/recently-played-playlists/master/create_tables.sql
mysql -u root < create_tables.sql
```

You need to insert a row into the `playlists`.`users` table with the tokens you received from the spotify auth flow.
Edit the following in the snippet below: `YOUR_USERNAME`, `YOUR_ACCESS_TOKEN`, `YOUR_REFERSH_TOKEN`
```
mysql -u playlist_user

use playlists;
insert into users (username, spotify_auth_token, spotify_refresh_token, time_of_last_track_played, expires_at) VALUES ('YOUR_USERNAME', 'YOUR_ACCESS_TOKEN', 'YOUR_REFRESH_TOKEN', '-1', '-1');
```

### Add secrets to recently-played-playlists .env file
Find where pip installed recently-played-playlists on your machine, and add a .env file in the root directory.

On Ubuntu 18.04, this should be `/usr/local/lib/python3.6/dist-packages/recently_played_playlists/.env`

Paste the following text into the file, replacing occurrences of `YOUR_SECRET` with your SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET.
```
SPOTIFY_CLIENT_ID=YOUR_SECRET
SPOTIFY_CLIENT_SECRET=YOUR_SECRET

DB_HOST=127.0.0.1
DB_USER=playlist_user
DB_PASS=
DB_NAME=playlists

FLASK_APP=recently_played_playlists/api/api.py
```

The puppet service 'playlists_api' likely failed when initially applying the recently_played_playlists module without `FLASK_APP` set. Re-run puppet to restart it.
```
systemctl restart playlists_api.service
```

Verify that the systemd service is running: 
```
systemctl status playlists_api.service
```

Trigger the `save-played-tracks` corn manually and verify that it works:
```
recently-played-playlists save-played-tracks
```

If you'd like, inspect `playlists`.`songs_played` to see that song plays have been populated. The max that Spotify returns at any point in time is 50. Therefore, if you have an extensive Spotify listening history, you should see 50 rows. Something like:
```
mysql -u playlist_user -e 'use playlists; select count(*) from songs_played;'
```

Woohoo! This is done.

### Installing recently-played-playlists-parser
This could be better, mostly if I packaged this code via opam.

```
cd ~/
git clone git@github.com:ndelnano/recently-played-playlists-parser.git
cd recently-played-playlists-parser
```

The recently-played-playlists-parser module installed opam and the apt packages that the parser depends on. Since this code isn't packaged as an opam package, we need to install the dependencies manually.

```
# Opam warns for running as root, but since this is the only ocaml code running on this host, I ignore it.
opam init

# Opam will tell you to run:
eval `opam config env`


bash install_deps.sh

```

#### Run the tests
```
make test
```

That should be it! You're probably excited to make your first playlist.....but you should probably wait until you have more data saved than only 50 track plays :-)
When you're ready, see the [docs to make playlists](https://github.com/ndelnano/recently-played-playlists-parser).

## This data seems important, are backups enabled?
In the root of this repo there's a file `do_droplet.tf`, which is terraform to create the DigitalOcean droplet that I run my installation on. 

For the low cost of $1/mo, this backs up the entire disk once per week. I'm OK with losing up to 1 week of data.

Maybe in the future I will implement a more frequent job to dump MySQL and upload to cloud storage.

### What if I want to add friends to my database?
Good question! I do this in my installation. Add another row in `playlists`.`users` with your friend's auth tokens. The `save-played-tracks` command polls the recently-played endpoint for all users in the `playlists`.`users` table.
