terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "ohbster-ado-terraform-class5"
    key    = "cloudfront/frontend/terraform.tfstate"
    region = "us-east-1"
  }
}

##Parametrize this
data "aws_s3_bucket" "bucket" {
    #bucket = "var="
  bucket = var.bucket_name
}

locals {
  content_types = {
    ".html" : "text/html",
    ".css" : "text/css",
    ".js" : "text/javascript",
    ".mp4" : "video/mp4",
    ".png" : "image/png",
    ".webm" : "video/webm"
  }
}

resource "aws_s3_object" "file" {
  for_each     = fileset(path.module, "content/**/*.{html,css,js,mp4,png,webm}")
  bucket       = data.aws_s3_bucket.bucket.id
  key          = replace(each.value, "/^content//", "")
  source       = each.value
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5(each.value)
  tags = var.common_tags
}
