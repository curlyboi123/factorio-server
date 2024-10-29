output "factorio_server_connection_string" {
  value = "${aws_instance.factorio_server.public_ip}:${local.factorio_port}"
}

output "factorio_server_instance_id" {
  value = aws_instance.factorio_server.id
}
