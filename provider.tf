provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Name    = "factorio"
      Project = "github.com/curlyboi123/factorio-server"
    }
  }
}
