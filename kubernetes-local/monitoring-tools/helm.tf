resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "55.5.0"

  atomic  = true
  timeout = 600

  depends_on = [
    kubernetes_namespace.monitoring
  ]

  values = [
    file("${path.module}/values.yaml")
  ]
}