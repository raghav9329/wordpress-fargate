###
# Depending on how you handle priviledge escalation you will need to either uncomment line for role_arn and session_name
# or lines shared_credentials_file, and profile
###
provider "aws" {
  region = var.region
  /* shared_credentials_file = "~/.aws/config" */
  profile = "default"
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/AdminRole"
    session_name = "demo"
  }
}

