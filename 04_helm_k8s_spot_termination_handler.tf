#####################################
# Helm: k8s-spot-termination-handler
#####################################
resource "helm_release" "k8s_spot_termination_handler" {
  name       = "k8s-spot-termination-handler"
  repository = "stable"
  chart      = "k8s-spot-termination-handler"
  version    = "1.0.0"
  namespace  = "kube-system"

  values = [
    <<EOF
rbac:
  create: true

serviceAccount:
  create: true

image:
  tag: 1.13.0-1

nodeSelector:
  ${local.spot_label}: "true"
EOF
    ,
  ]
}
