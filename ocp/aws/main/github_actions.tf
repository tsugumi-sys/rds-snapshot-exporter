/*
  IAM role for OIDC authentication to run some terraform commands in github actions.
*/
data "http" "github_actions_openid_configuration" {
  # see https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"

  request_headers = {
    Accept = "application/json"
  }
}

data "tls_certificate" "github_actions_certificate" {
  url = jsondecode(data.http.github_actions_openid_configuration.response_body).jwks_uri
}

resource "aws_iam_openid_connect_provider" "github_actions_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions_certificate.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_actions_oidc_role" {
  name               = "github_actions_oidc_role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_assume_role.json
}

data "aws_iam_policy_document" "github_actions_oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions_oidc.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:tsugumi-sys/rds-snapshot-exporter:*"]
    }
  }
}

data "aws_iam_policy_document" "github_actions_oidc_additional_policies" {
  /*
    Policies for creating, attaching, changing and deleting policies.
    Do not add policies for managing users and groups.
  */
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }

  statement {
    actions   = ["lambda:UpdateFunctionCode"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "oidc_iam_role_additional_policies" {
  name   = "oidc_iam_role_additional_policies"
  policy = data.aws_iam_policy_document.github_actions_oidc_additional_policies.json
}

resource "aws_iam_role_policy_attachment" "github_actions_oidc_additional_policies_attach" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = aws_iam_policy.oidc_iam_role_additional_policies.arn
}

# resource "aws_iam_role_policy_attachment" "power_user_access_attach" {
#   role       = aws_iam_role.github_actions_oidc_role.name
#   policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
# }

# resource "aws_iam_role_policy_attachment" "iam_read_only_access_attach" {
#   role       = aws_iam_role.github_actions_oidc_role.name
#   policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
# }

