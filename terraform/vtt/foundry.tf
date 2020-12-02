resource "digitalocean_droplet" "foundry" {
  image      = "ubuntu-20-04-x64"
  name       = "foundry-vtt"
  region     = var.region
  size       = var.foundry_size
  ssh_keys   = [data.digitalocean_ssh_key.ssh.id]
  backups    = false
  monitoring = false
}

resource "digitalocean_domain" "foundry" {
  name       = var.domain
  ip_address = digitalocean_droplet.foundry.ipv4_address
}

resource "digitalocean_firewall" "foundry" {
  name        = "ssh-and-web"
  droplet_ids = [digitalocean_droplet.foundry.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_allowlist
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
