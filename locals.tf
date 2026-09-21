locals {
  region        = "eu-west-1"
  my_ipv4       = "${chomp(data.http.my_ipv4.response_body)}/32"
  factorio_port = "34197"
}
