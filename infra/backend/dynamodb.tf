resource "aws_dynamodb_table" "lock" {
  name         = "${var.project_name}-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" # nome exigido pelo Terraform

  attribute {
    name = "LockID"
    type = "S"
  }
}