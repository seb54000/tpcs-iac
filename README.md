# tp-centralesupelec-iac
New iac tp (azure and vikunja)


This exercices are designed to be deployed by Terraform and ansible

For the terraform part, we could envisage 2 cloud provider
- AZURE (to have a new one)
- AWS

# AZURE

Using a microsoft online account associated with sebastien.claude@centralesupelec.fr
- not working, we have to use personnal account (as company account doesn't allow access to AD)
  - so using seabstien.claude@multiseb.com

https://portal.azure.com/

https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build

brew update && brew install azure-cli
az login
az account set --subscription "xxxxxxxxxx" # Note the subscription is the id (not the tenantid)
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/xxxxxxxxxx"



```
export ARM_CLIENT_ID="<APPID_VALUE>"
export ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<TENANT_VALUE>"
```

https://terraformguru.com/terraform-real-world-on-azure-cloud/10-Azure-Virtual-Network-4Tier/
https://www.dotnettricks.com/learn/azure/what-is-microsoft-azure-virtual-network-and-architecture
