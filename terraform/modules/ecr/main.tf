resource "aws_ecr_repository" "repo" {
  name = var.name

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.repo.name
  policy     = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "tagged"
          tagPrefixList = [""]
          countType    = "imageCountMoreThan"
          countNumber  = 30
        }
        action = { type = "expire" }
      }
    ]
  })
}

 