# Sufixo aleatorio: nome de bucket precisa ser unico no mundo inteiro
resource "random_id" "suffix" {
  byte_length = 4
}

# Learner Lab: a SCP nega s3:GetBucketObjectLockConfiguration, que o provider
# chama sempre que le um aws_s3_bucket. Por isso o bucket e criado via AWS CLI
# e o Terraform gerencia apenas as configuracoes dele (que nao fazem essa leitura).
locals {
  state_bucket_name = "${var.project_name}-tfstate-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = local.state_bucket_name

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = local.state_bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = local.state_bucket_name

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}