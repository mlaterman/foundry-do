variable "region" {
  type        = string
  description = "Digital Ocean region"
}

variable "domain" {
  type        = string
  description = "The domain used to access the foundry instance (for certs)."
}

variable "space_name" {
  type        = string
  description = "Space name to place backups in."
}

variable "foundry_size" {
  type        = string
  description = "Droplet size for foundry VM"
  default     = "s-1vcpu-1gb"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name"
}

variable "ssh_allowlist" {
  type        = list(string)
  description = "The CIDR blocks allowed to SSH onto droplets"
}

variable "retention_days" {
  type        = number
  description = "The number of days backups will be kept on the space"
  default     = 60
}
