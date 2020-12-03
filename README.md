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
* Python3 and pip3 installed
* [terraform](https://www.terraform.io/downloads.html) v0.13.5+ installed
* A [Terraform Cloud](https://app.terraform.io/) account

## Setup

1. Download FoundryVTT for Node and put it in this folder, with `foundry.yml`.
1. Run `./setup.sh` to ensure terraform is installed/logged in and to create an environment file.
1. Run `source .env` to use the environment file.
1. Change values in `terraform/deployment/backend.tfvars` to reflect your (terraform cloud) org and workspace, and `terraform/deployment/variables.tfvars` as needed (domain, SSH allowlist, etc.).
1. Plan the terraform changes by running `make plan`, this shows the changes that will occur on Digital Ocean.
1. Apply the terrafrom changes by running `make apply`, this creates the resources on Digital Ocean.
1. Active the python virtual environment by running `source venv/bin/activate`.
1. Install python requirements by running `make pip`
1. Install/configure FoundryVTT on the droplet by running `make ansible`

### Environment Variables

The `.env` file created exports the following:

| variable                | stage   | use                                        |
|-------------------------|---------|--------------------------------------------|
| DIGITALOCEAN_TOKEN      | deploy  | API token to deploy resources              |
| SPACES_ACCESS_KEY_ID    | deploy  | Spaces key to create a space               |
| SPACES_SECRET_ACESS_KEY | deploy  | Spaces secret to create a space            |
| BACKUP_ACCESS_KEY_ID    | ansible | Spaces key used by backup agent            |
| BACKUP_SECRET_ACESS_KEY | ansible | Spaces secret used by backup agent         |
| EMAIL                   | ansible | email for (HTTPS) certificate registration |
| FOUNDRY_ADMIN_KEY       | ansible | FoundryVTT admin password                  |

`deploy` variables are required for terraform.
`ansible` variables are required for ansible.

## Ansible

Ansible is used to install nginx, certbot, FoundryVTT, and a backup agent onto the droplet.

To install ansible, activate a virtual environment and run `make pip`.

Ensure that `ansible` variables are set (see [above](#environment-variables) and run `make ansible`.

**NOTE:** The ansible hosts file will be generated using output from terraform.

## Restoring FoundryVTT Data

The foundry role contains a script to deploy and schedule a backup agent.

In order to restore from a backup, ssh onto an instance and run:

```sh
export SPACES_ACCESS_KEY_ID=<ACCESS_KEY>  # spaces access key
export SPACES_SECRET_ACCESS_KEY=<SECRET>  # spaces access secret
/usr/local/spacesbackup/venv/bin/python3 /usr/local/spacesbackup/spacesbackup.py --restore=<KEY>  # spaces item key
chown foundry:foundry -R /home/foundry/FoundryVTT/Data
systemctl restart foundryvtt.service
```

