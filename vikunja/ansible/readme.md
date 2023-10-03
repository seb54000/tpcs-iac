
python3 -m venv ansiblevenv
source ansiblevenv/bin/activate
pip install -r requirements.txt

ansible -i aws_ec2.yml -m shell _Role_front -a "hostname" 



ansible-playbook -i aws_ec2.yml setup.yml 



ssh -v -i tp-iac -J ubuntu@35.180.33.147 ubuntu@35.180.17.44

terraform output -json front | jq -r '.[] | .public_ip[0]'
13.36.166.132

terraform output -json api | jq -r '.[] | .public_ip[0]'
13.38.59.235