#####################################
# Helm: cluster-autoscaler
#####################################
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "stable"
  chart      = "cluster-autoscaler"
  version    = "0.11.3"
  namespace  = "kube-system"

  values = [
    <<EOF
cloudProvider: aws
awsRegion: ${local.aws_region}
sslCertPath: /etc/ssl/certs/ca-bundle.crt

rbac:
  create: true

autoDiscovery:
  clusterName: ${module.cluster.cluster_id}

podAnnotations:
  iam.amazonaws.com/role: ${aws_iam_role.cluster_autoscaler.arn}

nodeSelector:
  ${local.ondemand_label}: "true"
EOF
    ,
  ]
}

#####################################
# IAM: cluster-autoscaler
#####################################
resource "aws_iam_role" "cluster_autoscaler" {
  name               = "${local.resource_prefix}_cluster_autoscaler"
  assume_role_policy = "${data.aws_iam_policy_document.kube2iam_assume_role_policy_for_pods.json}"
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${local.resource_prefix}_cluster_autoscaler"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = "${aws_iam_role.cluster_autoscaler.name}"
  policy_arn = "${aws_iam_policy.cluster_autoscaler.arn}"
}
