locals {
  tags = {
    Terraform   = "true"
    Owner       = "jetolink"
    Environment = terraform.workspace
  }

  buckets = {
    "jetolink-bucket" = {
      versioning_enabled = true
      logging            = false
      grant              = false
      cors_rule          = true
    },
  }

  jetolink_ecr_repos = {
    "jetolink-backend" = {
      scan_on_push = false
    }
    "jetolink-frontend" = {
      scan_on_push = false
    }
    "jetolink-chat-service" = {
      scan_on_push = false
    }
  }
  bucket_arns_wildcard = formatlist("%s/*", module.s3.bucket_arns)
  aws_iam_policy_settings = {
    "s3" : {
      actions = [
        "s3:Get*",
        "s3:List*",
        "s3:Put*"
      ]
      resources = concat(module.s3.bucket_arns, local.bucket_arns_wildcard)
    },
    "secretsmanager" : {
      actions = [
        "secretsmanager:Get*",
        "secretsmanager:List*"
      ]
      resources = ["*"]
    },
    "acm" : {
      actions = [
        "acm:Get*",
        "acm:List*",
        "acm:DescribeCertificate",
        "acm:RequestCertificate"
      ]
      resources = ["*"]
    },
    "elb" : {
      actions = [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners"
      ]
      resources = ["*"]
    },
    "sns" : {
      actions = [
        "sns:Publish"
      ]
      resources = ["*"]
    },
    "ses" : {
      actions = [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      resources = ["*"]
    },
    "api" : {
      actions = [
        "apigateway:POST"
      ]
      resources = ["*"]
    }
  }
}
