#####################################
# Helm: gitlab-runner
#####################################
resource "helm_release" "gitlab_runner" {
  name       = "gitlab-runner"
  repository = "gitlab"
  chart      = "gitlab-runner"
  version    = "0.2.0"
  namespace  = "default"

  values = [
    <<EOF
gitlabUrl: ${local.gitlab_host_name}
runnerRegistrationToken: ${local.gitlab_runner_registration_token}
concurrent: 50
checkInterval: 30

rbac:
  create: true

runners:
  image: ruby:2.5.1-alpine
  privileged: true

  cache:
    cacheType: s3
    cachePath: "gitlab_runner"
    cacheShared: true

    s3ServerAddress: s3.amazonaws.com
    s3BucketName: gitlab-runner-cache
    s3BucketLocation: ${local.aws_region}
    s3CacheInsecure: false
    secretName: gitlab-runner-cache-s3-access

  builds:
    cpuRequests: 1000m
    memoryRequests: 4096Mi
    cpuLimit: 1200m
    memoryLimit: 4096Mi

  services:
    cpuRequests: 500m
    memoryRequests: 2048Mi
    cpuLimit: 500m
    memoryLimit: 2048Mi

  helpers:
    cpuRequests: 500m
    memoryRequests: 2048Mi
    cpuLimit: 500m
    memoryLimit: 2048Mi

  nodeSelector:
    ${local.spot_label}: "true"

nodeSelector:
  ${local.ondemand_label}: "true"

envVars:
  - name: KUBERNETES_POD_ANNOTATIONS_OVERWRITE_ALLOWED
    value: ".*"
EOF
    ,
  ]
}

#####################################
# IAM: GitLab Runner Pods(Job)
#####################################
resource "aws_iam_role" "gitlab_runner" {
  name               = "${local.resource_prefix}_gitlab_runner"
  assume_role_policy = "${data.aws_iam_policy_document.kube2iam_assume_role_policy_for_pods.json}"
}

locals {
  gitlab_runner_attach_roles_arn_list = [
    "arn:aws:iam::1234567890:policy/my-gitlab-runner-policy",
  ]
}

resource "aws_iam_role_policy_attachment" "gitlab_runner" {
  count      = "${length(local.gitlab_runner_attach_roles_arn_list)}"
  role       = "${aws_iam_role.gitlab_runner.name}"
  policy_arn = "${local.gitlab_runner_attach_roles_arn_list[count.index]}"
}
