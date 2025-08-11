# Create a KMS Key for MSK encryption at rest
resource "aws_kms_key" "kms" {
  description = "jetolink msk kafka ${terraform.workspace}"
}

# Create a CloudWatch Log Group for MSK Broker logs
resource "aws_cloudwatch_log_group" "this" {
  name = "msk-broker-${terraform.workspace}-logs"

  tags = merge(
    {
      Environment = terraform.workspace,
      Name        = "jetolink-log-group-msk-kafka-${terraform.workspace}"
    },
    var.tags
  )
}

# Create the Amazon MSK (Managed Streaming for Apache Kafka) cluster
resource "aws_msk_cluster" "this" {
  number_of_broker_nodes = var.broker_count
  kafka_version          = var.kafka_version
  cluster_name           = "jetolink-msk-kafka-cluster-${terraform.workspace}"

  broker_node_group_info {
    client_subnets = var.private_subnets
    instance_type  = var.kafka_instance_type

    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }

    security_groups = [aws_security_group.msk_sg.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.this.name
      }
    }
  }

  tags = merge(
    {
      Environment = terraform.workspace,
      Name        = "jetolink-msk-kafka-${terraform.workspace}"
    },
    var.tags
  )
}

# Define local map for storing Kafka broker and Zookeeper TLS endpoints as SSM Parameters
locals {
  ssm_parameters = {
    "KAFKA_BROKER-chat-service-${terraform.workspace}"    = aws_msk_cluster.this.bootstrap_brokers_tls
    "KAFKA_ZOOKEEPER-chat-service-${terraform.workspace}" = aws_msk_cluster.this.zookeeper_connect_string_tls
  }
}

# Store MSK TLS endpoints in AWS SSM Parameter Store for service discovery
resource "aws_ssm_parameter" "params" {
  for_each = local.ssm_parameters

  type  = "String"
  name  = each.key
  value = each.value

  overwrite = true

  tags = merge(
    var.tags,
    {
      Environment = terraform.workspace
    }
  )

  depends_on = [aws_msk_cluster.this]
}
