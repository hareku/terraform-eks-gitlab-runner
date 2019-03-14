locals {
  aws_region      = "ap-northeast-1"
  project_name    = "gitlab-runner"
  resource_prefix = "eks-gitlab-runner"

  gitlab_host_name                 = "http://my-gitlab-server.com"
  gitlab_runner_registration_token = "xxxxxxx"

  resource_default_tags = {
    Environment = "ci"
  }

  vpc_id   = "vpc-xxxxxxxx"
  subnet_a = "subnet-xxxxx"
  subnet_c = "subnet-xxxxx"
  subnet_d = "subnet-xxxxx"

  ondemand_label = "ondemand"
  spot_label     = "spot"
}
