data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
  depends_on = [
    aws_eks_cluster.eks
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
  depends_on = [
    aws_eks_cluster.eks
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

resource "kubernetes_namespace" "monitoramento" {
  metadata {

    name = "monitoramento"
  }

  depends_on = [
    aws_eks_node_group.nodes_general
  ]
}

resource "kubernetes_namespace" "grafana" {
  metadata {

    name = "grafana"
  }

  depends_on = [
    aws_eks_node_group.nodes_general
  ]
}

#Sobe o serviço do prometheus
resource "helm_release" "prometheus" {
  name        = "prometheus"
  namespace   = kubernetes_namespace.monitoramento.id
  repository  = "https://prometheus-community.github.io/helm-charts"
  chart       = "prometheus"

  set {
    name      = "alertmanager.persistentVolume.storageClass" 
    value     = "gp2"
  }

  set {
    name      = "server.persistentVolume.storageClass"
    value     = "gp2"
  }

  depends_on = [
    kubernetes_namespace.monitoramento
  ]
}


#Criar serviço do grafana
resource "helm_release" "grafana" {
  name        = "grafana"
  namespace   = kubernetes_namespace.grafana.id
  repository  = "https://grafana.github.io/helm-charts"
  chart       = "grafana"

  set {
    name      = "persistence.storageClassName" 
    value     = "gp2"
  }

  set {
    name      = "adminPassword"
    value     = "admin123"
  }

  set {
    name      = "service.type"
    value     = "LoadBalancer"
  }
  

  set {
    name      = "service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value     = "grafana.${local.zone_dns}"
  }

  depends_on = [
    kubernetes_namespace.grafana
  ]
}