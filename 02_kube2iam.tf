#####################################
# Helm: kube2iam
#####################################
resource "helm_release" "kube2iam" {
  name       = "kube2iam"
  repository = "stable"
  chart      = "kube2iam"
  version    = "0.10.0"
  namespace  = "kube-system"

  values = [
    <<EOF
verbose: true
rbac:
  create: true
host:
  iptables: true
  interface: eni+
EOF
    ,
  ]
}

#####################################
# IAM: kube2iam
#####################################
data "aws_iam_policy_document" "kube2iam_assume_role_policy_for_worker" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kube2iam_assume_role_policy_for_worker" {
  name   = "${local.resource_prefix}_kube2iam_assume_role_policy_for_worker"
  path   = "/"
  policy = "${data.aws_iam_policy_document.kube2iam_assume_role_policy_for_worker.json}"
}

resource "aws_iam_role_policy_attachment" "kube2iam_assume_role_policy_for_worker" {
  role       = "${module.cluster.worker_iam_role_name}"
  policy_arn = "${aws_iam_policy.kube2iam_assume_role_policy_for_worker.arn}"
}

data "aws_iam_policy_document" "kube2iam_assume_role_policy_for_pods" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "AWS"
      identifiers = ["${module.cluster.worker_iam_role_arn}"]
    }
  }
}
