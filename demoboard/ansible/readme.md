# Demoboard Ansible

Cette première proposition remplace le déploiement Vikunja par une installation native de `demoboard` sur VM :

- `postgres` sur le rôle `_Role_db`
- `redis` sur le rôle `_Role_redis`
- `api-service` FastAPI dans un virtualenv Python + service `demoboard-api`
- `worker-service` Python dans un virtualenv Python + service `demoboard-worker`
- `frontend-service` buildé avec `npm` puis servi par `nginx`

## Préparation du contrôleur Ansible

```bash
sudo apt install -y python3-venv rsync
python3 -m venv ansiblevenv
source ansiblevenv/bin/activate
pip install -r requirements.txt
ansible-galaxy collection install -r collections/requirements.yml
```

Hypothèse actuelle :

- `tpcs-workstations` a déjà cloné le repo applicatif dans `~/tpcs-iac/demoboard/ansible/demoboard-source`
- les VMs sont découvertes via l’inventaire dynamique `aws_ec2.yml`

## Vérifications utiles

```bash
ansible-inventory -i aws_ec2.yml --graph
ansible -i aws_ec2.yml -m ping _Role_api
ansible-playbook -i aws_ec2.yml setup.yml
```

## Points à finaliser

- sécurisation Redis avec mot de passe si on veut éviter `protected-mode no`
- éventuellement builder les artefacts sur le contrôleur puis les pousser, au lieu de compiler sur chaque VM
- choix final sur la topologie réseau de l’API : ALB interne actuel dans cette proposition
