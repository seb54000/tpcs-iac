# tp-centralesupelec-iac

Le contenu TP applicatif AWS est désormais sous `demoboard/`.

Préparation minimale sur une VM étudiante :

```bash
ssh-keygen -f demoboard/terraform/tp-iac
source .env
terraform -chdir=demoboard/terraform init
ansible-galaxy collection install -r demoboard/ansible/collections/requirements.yml
```

Variables d’environnement attendues dans `.env` :

```bash
export AWS_ACCESS_KEY_ID=************
export AWS_SECRET_ACCESS_KEY=************
export AWS_DEFAULT_REGION=us-east-1
export TF_VAR_ssh_key_public=$(cat ~/tpcs-iac/demoboard/terraform/tp-iac.pub)
export TF_VAR_demoboard_aws_zones='["us-east-1a","us-east-1b","us-east-1c"]'
```
