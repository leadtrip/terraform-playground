environment = "prod"

services = {
  nginx = {
    image = "nginx:latest"
    ports = ["8080:80"]
  }

  postgres = {
    image = "postgres:15"
    ports = ["5432:5432"]
  }
}