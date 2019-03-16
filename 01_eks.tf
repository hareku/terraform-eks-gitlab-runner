####################################
# EKS
####################################
module "cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${local.project_name}-cluster"
  cluster_version = "1.11"
  vpc_id          = "${local.vpc_id}"

  subnets = [
    "${local.subnet_a}",
    "${local.subnet_c}",
    "${local.subnet_d}",
  ]

  config_output_path = "./config/"
  kubeconfig_name    = "kubeconfig"

  workers_group_defaults = {
    public_ip           = true
    autoscaling_enabled = true
  }

  worker_group_count = "2"

  worker_groups = [
    {
      name               = "ondemand_group"
      instance_type      = "t3.small"
      asg_max_size       = 1
      subnets            = "${local.subnet_d}"
      kubelet_extra_args = "--node-labels=${local.ondemand_label}=true"
    },
    {
      name               = "spot_group"
      instance_type      = "m4.2xlarge"
      spot_price         = "0.5"
      asg_max_size       = 20
      asg_min_size       = 0
      subnets            = "${local.subnet_a}"
      kubelet_extra_args = "--node-labels=${local.spot_label}=true"
    },
  ]

  worker_group_tags = {
    ondemand_group = []

    spot_group = [
      {
        key                 = "k8s.io/cluster-autoscaler/node-template/label/${local.spot_label}"
        value               = "true"
        propagate_at_launch = true
      },
    ]
  }

  tags = "${local.resource_default_tags}"
}
