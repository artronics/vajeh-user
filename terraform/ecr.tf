resource "aws_ecr_repository" "service_ecr" {
  name                 = local.name_prefix
  image_tag_mutability = "MUTABLE"
}
