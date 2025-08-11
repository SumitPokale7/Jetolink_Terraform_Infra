data "aws_caller_identity" "this" {}

module "network" {
  source                         = "../terraform-modules/network"
  azs                            = var.azs
  tags                           = var.tags
  vpc_name                       = var.vpc_name
  vpc_cidr                       = var.vpc_cidr
  enable_nat_gateway             = var.enable_nat_gateway
  single_nat_gateway             = var.single_nat_gateway
  public_subnet_cidrs            = var.public_subnet_cidrs
  private_subnets_cidrs          = var.private_subnets_cidrs
  default_security_group_ingress = var.default_security_group_ingress
}

resource "aws_ram_resource_share" "network_share" {
  allow_external_principals = false
  tags                      = var.tags
  name                      = "${var.aws_ram_resource_share_name}-${terraform.workspace}"
}

resource "aws_ram_principal_association" "dev_account" {
  for_each           = var.account_numbers
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.network_share.arn
}

# Share Private subnets
resource "aws_ram_resource_association" "private_subnets" {
  for_each = {
    for idx, subnet in module.network.private_subnets :
    "private-${idx + 1}" => subnet
  }

  resource_share_arn = aws_ram_resource_share.network_share.arn
  resource_arn       = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.this.account_id}:subnet/${each.value}"
}

# Share public subnets
resource "aws_ram_resource_association" "public_subnets" {
  for_each = {
    for idx, subnet in module.network.public_subnets :
    "public-${idx + 1}" => subnet
  }

  resource_share_arn = aws_ram_resource_share.network_share.arn
  resource_arn       = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.this.account_id}:subnet/${each.value}"
}

# Share security_group
resource "aws_ram_resource_association" "vpc_security_group" {
  resource_share_arn = aws_ram_resource_share.network_share.arn
  resource_arn       = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.this.account_id}:security-group/${module.network.vpc_security_group_id}"
}
