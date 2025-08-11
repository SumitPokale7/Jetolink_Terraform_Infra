region                      = "us-east-1"
zone_name                   = "jetolink.com"
account_numbers             = [159773342471]
aws_ram_resource_share_name = "shared-network-resources"

#Network
enable_nat_gateway    = true
single_nat_gateway    = true
vpc_name              = "jetolink"
vpc_cidr              = "10.217.10.0/23"
azs                   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs   = ["10.217.10.0/27", "10.217.10.64/27"]
private_subnets_cidrs = ["10.217.10.128/26", "10.217.11.0/26"]

default_security_group_ingress = [
  {
  "from_port"   = "5432"
  "to_port"     = "5432"
  "protocol"    = "tcp"
  "description" = "Allow PostgreSQL"
  },
   {
  "from_port"   = "9092"
  "to_port"     = "9092"
  "protocol"    = "tcp"
  "description" = "Allow Msk-Kafka"
  },
   {
  "from_port"   = "6379"
  "to_port"     = "6379"
  "protocol"    = "tcp"
  "description" = "Allow Redis"
  }
]
