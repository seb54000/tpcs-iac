# tp-centralesupelec-iac

`ssh-keygen -f tp-iac`


Description des attendsu du .env

export AWS_ACCESS_KEY_ID=************
export AWS_SECRET_ACCESS_KEY=************
export AWS_DEFAULT_REGION=us-east-1

export TF_DATA_DIR=~/tp-centralesupelec-iac/terraform/.terraform
export TF_VAR_ssh_key_public=$(cat ~/tp-centralesupelec-iac/terraform/tp-iac.pub)