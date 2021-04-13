default: plan

configure:
	cd terraform/vtt; terraform init -backend-config=../deployment/backend.tfvars

plan: configure
	cd terraform/vtt; terraform plan -var-file=../deployment/variables.tfvars -out=terraform.plan

apply:
	cd terraform/vtt; terraform apply terraform.plan

pip:
	pip3 install -r requirements.txt

hosts:
	bash genhosts.sh

ansible: hosts
	ansible-playbook -i hosts --extra-vars="certbot_email=${EMAIL}" --extra-vars="foundry_key=${FOUNDRY_ADMIN_KEY}" --extra-vars="foundry_backup_space_key=${SPACES_ACCESS_KEY_ID}" --extra-vars="foundry_backup_space_secret=${SPACES_SECRET_ACCESS_KEY}" foundry.yml

.PHONY: default configure plan apply pip hosts ansible
