# Terraform for GitLab Runner on EKS

## Setup

1. terraform apply only `01_eks.tf` (You should comment out the `helm` provider)
2. `kubectl apply --kubeconfig=config/kubeconfig -f manifest/tiller-sa.yaml`
3. `helm init --kubeconfig=config/kubeconfig --service-account=tiller`

### S3 Cache Store
If you want to use `s3` cache store, create a secret for AWS authorization.

```
$ kubectl create secret generic gitlab-runner-cache-s3-access \
  --from-literal=accesskey="YourAccessKey" \
  --from-literal=secretkey="YourSecretKey"
```
