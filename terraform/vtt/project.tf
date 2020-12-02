resource "digitalocean_project" "vtt" {
  name        = "FoundryVTT"
  description = "A project to host FoundryVTT"
  purpose     = "Web Application"
  resources   = [
    digitalocean_droplet.foundry.urn,
    digitalocean_domain.foundry.urn,
    digitalocean_spaces_bucket.space.urn
  ]
}
