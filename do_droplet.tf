# Create a new Droplet in the nyc2 region
# Smallest instance size, $5/month
# Use `backups = true` in place of a real MySQL backup solution :)
resource "digitalocean_droplet" "web" {
  image  = "ubuntu-18-04-x64"
  name   = "playlist-maker"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  backups = true
  monitoring = true
}
