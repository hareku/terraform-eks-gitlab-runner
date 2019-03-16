# Terraform for GitLab Runner on EKS

## Setup

1. terraform apply only `01_eks.tf` (You should comment out the `helm` and `kubernetes` provider)
2. `kubectl apply --kubeconfig=config/kubeconfig -f manifest/tiller-sa.yaml`
3. `helm init --kubeconfig=config/kubeconfig --service-account=tiller`

### S3 Cache Store
If you want to use `s3` cache store, create a secret for AWS auth.

```bash
$ kubectl create secret generic gitlab-runner-cache-s3-access \
  --kubeconfig=config/kubeconfig
  --namespace=gitlab-runner
  --from-literal=accesskey="YourAccessKey" \
  --from-literal=secretkey="YourSecretKey"
```

### kube2iam
If Pod needs AWS auth, set IAM role arn to `.gitlab-ci.yml` for kube2iam.

```yaml
variables:
  KUBERNETES_POD_ANNOTATIONS_1: "iam.amazonaws.com/role=arn:aws:iam::1234567890:role/gitlab-runner-ci-role"
```
