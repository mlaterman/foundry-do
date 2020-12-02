data "digitalocean_ssh_key" "ssh" {
  name = var.ssh_key_name
}
