# Exemple pédagogique : un module qui masque trois providers

Cet exemple montre le même module appelé deux fois, une fois pour AWS et une fois pour Google Cloud, avec trois choix (`cloud`, `size` et `image`) écrits dans chaque appel. Le module contient trois ressources différentes et chaque appel n'en crée qu'une : AWS, Google Cloud ou Azure. Il ne constitue pas une abstraction portable fournie par Terraform : le développeur a choisi les tailles, les images, les régions et les réseaux, et doit maintenir ces correspondances.

## À lire avant tout essai

Ce répertoire est une illustration, pas une configuration prête à appliquer. Les identifiants d'images, projet, sous-réseau et groupe de ressources sont des marqueurs à remplacer. Les images et les tailles doivent être vérifiées dans chaque région et chaque compte. Les tailles S/M/L sont des catégories approximatives définies pour cet exemple, pas des équivalences de performance entre clouds. Azure ne fournit pas un « VPC par défaut » universel comme l'exemple AWS/GCP : le sous-réseau Azure est donc un choix fixe à fournir.

Les trois providers sont déclarés dans la configuration appelante et hérités automatiquement par le module, car il n'y a qu'une configuration par provider. La variable `cloud` ne choisit pas dynamiquement un provider Terraform : des blocs de ressources statiquement écrits sont activés ou désactivés avec `count`. En pratique, un projet multi-cloud peut préférer des modules séparés par provider, avec une couche d'orchestration au-dessus.

Pour étudier le code sans créer de ressource, commencer par `main.tf` : il contient deux appels au module et les trois choix transmis dans chacun. `providers.tf` rassemble la configuration des providers et `outputs.tf` expose les identifiants retournés. Lire ensuite `modules/vm/variables.tf`, `main.tf` et `outputs.tf` pour voir comment le module interprète ces choix. Les variables et leurs validations sont internes au module ; le code appelant passe directement des valeurs. Les identifiants d'infrastructure sont volontairement fictifs.

## Correspondances illustratives

| Choix | AWS | Google Cloud | Azure |
| --- | --- | --- | --- |
| S | `t3.micro` | `e2-micro` | `Standard_B1s` |
| M | `t3.small` | `e2-small` | `Standard_B2s` |
| L | `t3.medium` | `e2-medium` | `Standard_B2ms` |
| Ubuntu | AMI à renseigner pour la région AWS | image de projet/famille à renseigner | image ID à renseigner |
| Fedora | AMI à renseigner pour la région AWS | image de projet/famille à renseigner | image ID à renseigner |

Les valeurs AWS et Azure dans `locals` sont des marqueurs (`REPLACE_ME_*`), pas des identifiants valides. Pour GCP, les noms d'images sont également à confirmer et à adapter au projet et à la région choisis.

## Entrées et sortie

- `cloud` : `aws`, `gcp` ou `azure`.
- `size` : `S`, `M` ou `L`.
- `image` : `ubuntu` ou `fedora`.
- Chaque appel expose son identifiant de VM via l'output `vm_id` du module.

Le code suppose que les credentials sont configurés hors du dépôt. Il n'y a pas de secrets dans les fichiers d'exemple.


