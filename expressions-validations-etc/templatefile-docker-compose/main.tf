locals {

  monitoring_services = {
    prometheus = {
      image = "prom/prometheus:latest"
      ports = ["9090:9090"]
    }

    grafana = {
      image = "grafana/grafana:latest"
      ports = ["3000:3000"]
    }
  }

  effective_services = (
    var.environment == "prod"
    ? merge(var.services, local.monitoring_services)
    : var.services
  )

  rendered_compose = templatefile("${path.module}/docker-compose.yml.tftpl", {
    services    = local.effective_services
    environment = var.environment
  })
}

resource "local_file" "docker_compose" {
  filename = "${path.module}/docker-compose.yml"
  content  = local.rendered_compose
}

output "environment_used" {
  value = var.environment
}