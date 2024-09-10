provider "aws" {
  region = "us-east-1"
}

resource "aws_organizations_organization" "main" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "sso.amazonaws.com",
    "account.amazonaws.com",
  ]
  
}

data "aws_ssoadmin_instances" "main" {
    depends_on = [ aws_organizations_organization.main ]
}

data "aws_caller_identity" "current" {}


resource "aws_ssoadmin_permission_set" "admin_access" {
  name         = "AdminAccess2"
  description  = "Admin access to all AWS services"
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "admin_access" {
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
}

resource "aws_identitystore_user" "main" {
  identity_store_id = data.aws_ssoadmin_instances.main.identity_store_ids[0]
  display_name      = "John"
  user_name         = "john"

  emails {
    value = "ned.bellavance+john@gmail.com"
  }

  name {
    given_name  = "John"
    family_name = "Wick"
  }
}

resource "aws_identitystore_group" "admin_access" {
  display_name      = "AllAccountAdmins"
  identity_store_id = data.aws_ssoadmin_instances.main.identity_store_ids[0]
  description       = "Admins for all accounts"
}

resource "aws_identitystore_group_membership" "admin_access" {
  identity_store_id = data.aws_ssoadmin_instances.main.identity_store_ids[0]
  group_id          = aws_identitystore_group.admin_access.group_id
  member_id         = aws_identitystore_user.main.user_id
}

resource "aws_ssoadmin_account_assignment" "admin_access" {
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
  principal_id       = aws_identitystore_group.admin_access.group_id
  principal_type     = "GROUP"
  target_id          = data.aws_caller_identity.current.id
  target_type        = "AWS_ACCOUNT"
}