locals {
  rendered_user_data = templatefile("${path.module}/user-data.tftpl", {
    environment          = var.environment
    enable_extra_message = var.enable_extra_message
    extra_message        = var.extra_message
  })
}

output "rendered_script" {
  value = local.rendered_user_data
}