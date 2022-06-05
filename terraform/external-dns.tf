#Cria external DNS
resource "helm_release" "external_dns" {
  count       = 1
  name        = "external-dns"
  namespace   = "kube-system"
  repository  = "https://kubernetes-sigs.github.io/external-dns/"
  chart       = "external-dns"
  cleanup_on_fail = true

  set {
    name      = "rbac.create"
    value     = "true"
  }

  depends_on = [
    aws_eks_node_group.nodes_general
  ]

  values = [
    "${data.template_file.external-dns[0].rendered}"
  ]
}


data "template_file" "external-dns" {
  count     = 1
  template  = file("templates/external-dns.yaml.tpl")
}
