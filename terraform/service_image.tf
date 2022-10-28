locals {
  lambda_src_dir = "${path.module}/../resolver"
  service_image_tag = local.environment
}

data "archive_file" "lambda_src_archive" {
  type        = "zip"
  source_dir  = local.lambda_src_dir
  output_path = "build/resolver.zip"
}

resource "null_resource" "resolver_image_push" {
  depends_on = [aws_ecr_repository.service_ecr]

  triggers   = {
    src_hash = data.archive_file.lambda_src_archive.output_sha
  }

  provisioner "local-exec" {
    command = "make docker-push-service"
  }
}

data "aws_ecr_image" "resolver_image" {
  depends_on = [
    null_resource.resolver_image_push
  ]
  repository_name = aws_ecr_repository.service_ecr.name
  image_tag       = local.service_image_tag
}
