resource "digitalocean_spaces_bucket" "space" {
  name   = var.space_name
  region = var.region
  acl    = "private"

  lifecycle_rule {
    id      = "backup-retention"
    prefix  = "foundry"
    enabled = true

    expiration {
      days = var.retention_days
    }
  }
}
