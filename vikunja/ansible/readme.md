# Setup environment and simple ansible tests

``` bash
python3 -m venv ansiblevenv
source ansiblevenv/bin/activate
# pip install ansible boto3 botocore
pip install -r requirements.txt
ansible-galaxy collection install community.mysql
```

`ansible -i aws_ec2.yml -m shell _Role_front -a "hostname"`

ansible-playbook -i aws_ec2.yml setup.yml

    --start-at-task="deploy nginx conf"

IP=$(ansible-inventory -i aws_ec2.yml --host front1 | jq -r '.public_ip_address')
sed -i -e "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/${IP}/g" ssh-config

ssh -v -i tp-iac -J ubuntu@35.180.33.147 ubuntu@35.180.17.44

ssh -F ssh-config 35.180.172.168

terraform output -json front | jq -r '.[] | .public_ip[0]'
13.36.166.132

terraform output -json api | jq -r '.[] | .public_ip[0]'
13.38.59.235

terraform output lb-front
curl lb-front-593290134.eu-west-3.elb.amazonaws.com/monitor.html

In CHROME browser, need INCOGNITO mode + Shift refresh in order to LoadBalance (otherwise, it is always going to the same nginx) - problem does not occur with curl

* https://stackoverflow.com/questions/29854860/session-cookie-not-remove-on-browser-close

## ansible galaxy commands

ansible-galaxy role list
ansible-galaxy role remove namespace.role_name

By default, Ansible downloads roles to the first writable directory in the default list of paths ~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles. This installs roles in the home directory of the user running ansible-galaxy.

You can override this with one of the following options:

* Set the environment variable ANSIBLE_ROLES_PATH in your session.
* Use the --roles-path option for the ansible-galaxy command.
* Define roles_path in an ansible.cfg file.
