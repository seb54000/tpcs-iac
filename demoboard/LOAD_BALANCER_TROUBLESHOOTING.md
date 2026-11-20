# Diagnostiquer la répartition du load balancer front

Le load balancer applicatif `lb-front-<nom-de-la-VM>` envoie les requêtes HTTP vers les deux instances front. La page `/monitor.html` affiche le nom et l'adresse privée de l'instance qui a répondu. L'Application Load Balancer choisit une cible à chaque requête ; son algorithme par défaut est le round robin. Cela ne promet pas une alternance visible stricte sur une courte série de requêtes : plusieurs nœuds du LB peuvent recevoir le trafic, et chaque nœud choisit une cible saine. Le groupe de cibles front n'active pas explicitement l'affinité de session dans Terraform. [Documentation AWS sur les attributs du target group](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/edit-target-group-attributes.html)

## Tester depuis la VM étudiante

Depuis `demoboard/terraform`, récupérer le DNS du LB puis envoyer des requêtes indépendantes à `monitor.html` :

```bash
LB_DNS=$(terraform output -raw lb-front)
for i in $(seq 1 20); do
  printf '%02d ' "$i"
  curl --silent --show-error --fail \
    -H 'Cache-Control: no-cache' -H 'Pragma: no-cache' \
    "http://${LB_DNS}/monitor.html?probe=${i}-$(date +%s%N)" \
    | grep -E 'Welcome on host|Actual hostname is|Private IP address'
done
```

Chaque invocation de `curl` ouvre un nouveau processus, n'envoie pas de cookie et utilise une URL distincte. Cela écarte le cache HTTP du client et la réutilisation d'une connexion curl. Le cache-busting ne change pas le choix du backend par le load balancer. Vérifier le nom et l'IP de chaque backend dans les réponses. Comparer aussi avec plusieurs fenêtres privées ou plusieurs clients si le résultat semble propre à un poste ou à un navigateur.

Pour voir la réponse HTTP complète d'une requête :

```bash
curl --verbose --no-keepalive \
  -H 'Cache-Control: no-cache' -H 'Pragma: no-cache' \
  "http://${LB_DNS}/monitor.html?probe=$(date +%s%N)"
```

## Vérifier la configuration et l'état des cibles avec AWS CLI

À exécuter avec les identifiants du compte et la région du TP. Le nom de VM locale sert de suffixe aux ressources créées par Terraform :

```bash
VM=$(hostname -s)
LB_NAME="lb-front-${VM}"
TG_NAME="lb-tg-front-${VM}"

LB_ARN=$(aws elbv2 describe-load-balancers \
  --names "$LB_NAME" --query 'LoadBalancers[0].LoadBalancerArn' --output text)
TG_ARN=$(aws elbv2 describe-target-groups \
  --names "$TG_NAME" --query 'TargetGroups[0].TargetGroupArn' --output text)

aws elbv2 describe-load-balancers --load-balancer-arns "$LB_ARN" \
  --query 'LoadBalancers[0].{Name:LoadBalancerName,DNS:DNSName,State:State.Code,Type:Type,AZs:AvailabilityZones[].ZoneName}' \
  --output table

aws elbv2 describe-listeners --load-balancer-arn "$LB_ARN" \
  --query 'Listeners[].{Port:Port,Protocol:Protocol,DefaultActions:DefaultActions}' --output json

aws elbv2 describe-target-groups --target-group-arns "$TG_ARN" \
  --query 'TargetGroups[0].{Name:TargetGroupName,Protocol:Protocol,Port:Port,HealthCheckPath:HealthCheckPath,HealthCheckInterval:HealthCheckIntervalSeconds,HealthyThreshold:HealthyThresholdCount,UnhealthyThreshold:UnhealthyThresholdCount,Matcher:Matcher.HttpCode}' \
  --output table

aws elbv2 describe-target-health --target-group-arn "$TG_ARN" \
  --query 'TargetHealthDescriptions[].{Instance:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason,Details:TargetHealth.Description}' \
  --output table

aws elbv2 describe-target-group-attributes --target-group-arn "$TG_ARN" \
  --query 'Attributes[?contains(Key, `stickiness`) || contains(Key, `load_balancing.algorithm`)]' \
  --output table
```

Les deux instances attendues doivent apparaître dans `describe-target-health` avec l'état `healthy`. En cas d'échec, examiner `Reason` et `Details`, puis vérifier que nginx répond sur le port 80 et que le health check du target group correspond à la configuration. Le target group front utilise les paramètres de health check par défaut d'AWS ; le target group API, lui, définit explicitement `/healthz` et le matcher `200`.

Pour retrouver les ARN sans connaître le suffixe de nom, lister les ressources de la région puis filtrer sur les tags `Name` et `filter` :

```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,ARN:LoadBalancerArn}' --output table
aws elbv2 describe-target-groups --query 'TargetGroups[].{Name:TargetGroupName,ARN:TargetGroupArn,Port:Port}' --output table
```

## Examiner dans la console AWS

Dans la région du TP, ouvrir **EC2 → Load Balancers**, sélectionner `lb-front-<nom-de-la-VM>` et contrôler son état, ses zones de disponibilité et son listener HTTP:80. Depuis l'onglet de listener, suivre le groupe de cibles associé. Dans **EC2 → Target Groups**, sélectionner `lb-tg-front-<nom-de-la-VM>` puis l'onglet **Targets / Cibles enregistrées** : les deux instances front doivent être enregistrées et avoir l'état **Healthy**. Ouvrir les détails d'une cible non saine pour lire la raison et les détails du health check.

## Interpréter les résultats

- Si une seule cible est saine, le load balancer n'enverra le trafic qu'à celle-ci : résoudre d'abord le health check ou l'accès réseau.
- Si les deux sont saines mais que `curl` ne montre qu'un seul backend, prolonger l'essai et comparer depuis un autre client ; un petit échantillon ne permet pas de conclure à une panne.
- Si le nom ou l'IP affiché change avec `curl` mais pas dans le navigateur, vérifier le cache du navigateur et les extensions/proxy. Une fenêtre privée et un rechargement forcé aident à isoler le client.
- Si un client seulement reste sur un backend, noter l'URL, l'heure, le réseau, le navigateur, les éventuels cookies et les sorties des commandes ci-dessus. Vérifier en particulier si le navigateur ou un proxy maintient une connexion persistante ; la répétition d'une requête par curl fournit un contrôle indépendant.

Les Application Load Balancers répartissent les requêtes selon l'algorithme configuré et l'affinité, si elle est activée. Le round robin par défaut répartit les requêtes entre les cibles saines ; l'affinité est désactivée par défaut. Un résultat observé sur quelques clics n'est donc pas une preuve suffisante d'un défaut de répartition ; confronter les réponses HTTP aux états des cibles et aux attributs du target group. [Documentation AWS sur l'algorithme et les sessions persistantes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/edit-target-group-attributes.html)
