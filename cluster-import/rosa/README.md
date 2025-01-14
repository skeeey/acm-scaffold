# Preparation

## ROSA Classic

```sh
rosa create account-roles --mode auto --prefix <prefix>
rosa create cluster --cluster-name=<cluster-name> --region=<region> --sts --mode=auto
```

## ROSA HPC

```sh
rosa create account-roles --mode auto --prefix <prefix>
rosa create oidc-config --mode=auto --yes
rosa create operator-roles --prefix <prefix> --oidc-config-id <oidc-config-id>
rosa create cluster --region=<region> --cluster-name=<cluster-name> --mode=auto \
    --billing-account=<billing-account> \
    --subnet-ids=<subnet-ids> \
    --sts --oidc-config-id <oidc-config-id> --operator-roles-prefix <prefix> --hosted-cp
```
