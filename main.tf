terraform {
  required_version = ">= 1.5.0"
}

resource "terraform_data" "test" {
  input = "GitHub Actions Terraform Test"
}

output "message" {
  value = terraform_data.test.output
}
