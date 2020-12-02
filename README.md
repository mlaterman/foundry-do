# foundry-do

Project can be used to deploy [foundry-vtt](https://foundryvtt.com/) to [Digital Ocean](https://www.digitalocean.com/).

Foundry can be accessed by the domain name that is passed.

Foundry will be deployed behind nginx with SSL certs.

Daily backups of Foundry's (user) data directory will be taken and pushed into a Digital Ocean Space if credentials are provided when running Ansible.

## Requirements

* A Digital Ocean account
  * Add an SSH key
  * Generate an access token and spaces tokens
* A Foundry license
* [terraform](https://www.terraform.io/downloads.html) v0.13.5+ installed
* A [Terraform Cloud](https://app.terraform.io/) account
* Python3 and pip3 installed

## Setup

1. Change values in `terraform/deployment/backend.tfvars` to reflect your (terraform cloud) org and workspace, and `terraform/deployment/variables.tfvars` as needed (i.e, SSH allowlist)
1. Login to Terrafrom Cloud with `terrafrom login`
1. Set the env var `DIGITALOCEAN_TOKEN` to an access token to your Digital Ocean account, and `SPACES_ACCESS_KEY_ID` and `SPACES_SECRET_ACCESS_KEY` to the spaces access keys.
1. Set the env var `DOMAIN` to the your domain, and `FOUNDRY_ADMIN_KEY` to the administration key you would like to use with foundry.
1. Set the env var `EMAIL` to your email address (used for certbot registration).
1. Download FoundryVTT for Node and put it in this folder, with `foundry.yml`.

## Deployment

To deploy a new space, and droplet with firewalls to Digital Ocean:

1. Run `make plan`
1. Run `make apply`

## Install and Configure

Ansible is used to install Foundry, certbot, and nginx onto the droplet.

To install ansible into a virtual environment run `make pip`.

Ensure that spaces credentials are set in the environment, as well as the `FOUNDRY_ADMIN_KEY`, then run `make ansible`.

**BEST PRACTICE:** Change the Spaces credentials in the environment variable to one dedicated for the droplet.

## TODO

3. provide better way of gathering user variables
