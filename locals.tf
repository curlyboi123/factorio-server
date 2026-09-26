locals {
  region        = "eu-west-1"
  my_ipv4       = "${chomp(data.http.my_ipv4.response_body)}/32"
  factorio_port = "34197"

  # factorio_version      = "2.0.77"
  # factorio_download_url = "https://www.factorio.com/get-download/${local.factorio_version}/headless/linux64"

  factorio_asset_bucket = "john-factorio-assets"
}
