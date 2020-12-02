output "foundry_ip" {
  value = digitalocean_droplet.foundry.ipv4_address
}

output "space_name" {
  value = digitalocean_spaces_bucket.space.name
}

output "space_region" {
  value = digitalocean_spaces_bucket.space.region
}

output "domain" {
  value = var.domain
}
