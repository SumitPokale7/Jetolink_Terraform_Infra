
# KMS Key for SSM Parameters
# This key is used to encrypt SSM SecureString parameters.
# This Paramter will be used in ECS task definitions and other services that require secure storage of sensitive information.
resource "aws_kms_key" "ssm_key" {
  deletion_window_in_days = 7
  enable_key_rotation     = true
  description             = "KMS key for encrypting SSM SecureString parameters"

  tags = merge(
    var.tags,
    {
      Environment = terraform.workspace
      Name        = "kms-key-ssm-parameters"
    }
  )
}

resource "aws_kms_alias" "ssm_key_alias" {
  name          = "alias/ssm-parameters-encryption-key-${terraform.workspace}"
  target_key_id = aws_kms_key.ssm_key.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ssm_parameter" "params" {
  for_each = var.ssm_parameters

  name  = each.key
  type  = each.value.type
  value = sensitive(each.value.value)

  key_id = each.value.type == "SecureString" ? aws_kms_key.ssm_key.arn : null

  overwrite = true

  tags = merge(
    var.tags,
    {
      Environment = terraform.workspace
    }
  )
}
