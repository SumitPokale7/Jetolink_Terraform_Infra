region = "us-east-1"

#Postgress
backup_retention_period = 1
deletion_protection     = false
skip_final_snapshot     = true
engine_version          = "15.3"
rds_instance_class      = "db.r5.large"
preferred_backup_window = "04:29-04:59"
engine                  = "aurora-postgresql"

#Redis
num_node_groups            = 1
replicas_per_node_group    = 1
cluster_size               = 4
redis_port                 = 6379
automatic_failover_enabled = true
multi_az_enabled           = true
transit_encryption_enabled = true
at_rest_encryption_enabled = true
redis_engine_version       = "7.0"
redis_engine               = "redis"
family                     = "redis7"
redis_instance_type        = "cache.t2.micro"

#Msk Kafka
broker_count        = 4
kafka_version       = "3.2.0"
kafka_instance_type = "kafka.t3.small"

#Container
ecs_services = {
  "jetolink-frontend" = {
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }
    ]
    cpu                     = "512"
    memory                  = "1024"
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
    environment = [
      {
        "name" : "NODE_ENV",
        "value" : "development"
      }
    ]
    secrets = [
      {
        "name" : "NEXT_PUBLIC_BACKEND_URL",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_PUBLIC_BACKEND_URL-frontend-dev"
      },
      {
        "name" : "ECS_MEDIA_PREFIX",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/ECS_MEDIA_PREFIX-frontend-dev"
      },
      {
        "name" : "NEXT_PUBLIC_SOCKET_URL",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_PUBLIC_SOCKET_URL-frontend-dev"
      },
      {
        "name" : "NEXTAUTH_URL",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXTAUTH_URL-frontend-dev"
      },
      {
        "name" : "NEXTAUTH_SECRET",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXTAUTH_SECRET-frontend-dev"
      },
      {
        "name" : "GOOGLE_CLIENT_ID",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/GOOGLE_CLIENT_ID-frontend-dev"
      },
      {
        "name" : "GOOGLE_CLIENT_SECRET",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/GOOGLE_CLIENT_SECRET-frontend-dev"
      },
      {
        "name" : "NEXT_PUBLIC_API_SECRET",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_PUBLIC_API_SECRET-frontend-dev"
      },
      {
        "name" : "NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY-frontend-dev"
      },
      {
        "name" : "NEXT_PUBLIC_PAYPAL_CLIENT_ID",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_PUBLIC_PAYPAL_CLIENT_ID-frontend-dev"
      },
      {
        "name" : "NEXT_AWS_ACCESS_KEY_ID",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_AWS_ACCESS_KEY_ID-frontend-dev"
      },
      {
        "name" : "NEXT_S3_SECRET",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_S3_SECRET-frontend-dev"
      },
      {
        "name" : "NEXT_PUBLIC_S3_REGION",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_PUBLIC_S3_REGION-frontend-dev"
      },
      {
        "name" : "NEXT_PUBLIC_S3_BUCKET",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/NEXT_PUBLIC_S3_BUCKET-frontend-dev"
      }
    ]
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
      timeout     = 5
      retries     = 3
      interval    = 30
      startPeriod = 20
    }
    alb_health_check = [{
      timeout             = 5
      healthy_threshold   = 3
      unhealthy_threshold = 3
      interval            = 30
      matcher             = "200"
      path                = "/api/health"
    }]
  }

  "jetolink-backend" = {
    portMappings = [
      {
        containerPort = 8000
        hostPort      = 8000
        protocol      = "tcp"
      }
    ]
    cpu                     = "1024"
    memory                  = "2048"
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
    environment = [
      {
        "name" : "PORT",
        "value" : "8000"
      }
    ]
    secrets = [
      {
        "name" : "API_SECRET",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/API_SECRET-backend-dev"
      },
      {
        "name" : "PAYPAL_CLIENT_ID",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/PAYPAL_CLIENT_ID-backend-dev"
      },
      {
        "name" : "STRIPE_SECRET_KEY",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/STRIPE_SECRET_KEY-backend-dev"
      },
      {
        "name" : "EVERSEND_CLIENT_ID",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/EVERSEND_CLIENT_ID-backend-dev"
      },
      {
        "name" : "EVERSEND_BASE_URL",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/EVERSEND_BASE_URL-backend-dev"
      },
      {
        "name" : "DATABASE_URL",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/DATABASE_URL-backend-dev"
      },
      {
        "name" : "PAYPAL_CLIENT_SECRET",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/PAYPAL_CLIENT_SECRET-backend-dev"
      },
      {
        "name" : "EVERSEND_CLIENT_SECRET",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/EVERSEND_CLIENT_SECRET-backend-dev"
      }
    ]
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8000/health-check || exit 1"]
      timeout     = 5
      retries     = 3
      interval    = 30
      startPeriod = 20
    }
    alb_health_check = [{
      timeout             = 5
      healthy_threshold   = 3
      unhealthy_threshold = 3
      interval            = 30
      matcher             = "200"
      path                = "/health-check"
    }]
  }

  "jetolink-chat-service" = {
    portMappings = [
      {
        containerPort = 9000
        hostPort      = 9000
        protocol      = "tcp"
      }
    ]
    cpu                     = "1024"
    memory                  = "2048"
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
    environment = [
      {
        "name" : "PORT",
        "value" : "9000"
      },
      {
        "name" : "REDIS_USERNAME",
        "value" : ""
      },
      {
        "name" : "REDIS_PORT",
        "value" : "6379"
      },
      {
        "name" : "KAFKA_FROM_BEGINNING",
        "value" : "false"
      }
    ]
    secrets = [
      {
        "name" : "REDIS_PASSWORD",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/REDIS_PASS-chat-service-dev"
      },
      {
        "name" : "KAFKA_ZOOKEEPER",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/KAFKA_ZOOKEEPER-chat-service-dev"
      },
      {
        "name" : "BACKEND_URL",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/BACKEND_URL-chat-service-dev"
      },
      {
        "name" : "KAFKA_BROKERS",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/KAFKA_BROKER-chat-service-dev"
      },
      {
        "name" : "REDIS_HOST",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/REDIS_HOST-chat-service-dev"
      },
      {
        "name" : "DATABASE_URL",
        "valueFrom" : "arn:aws:ssm:us-east-1:159773342471:parameter/DATABASE_URL-chat-service-dev"
      }
    ]
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:9000/health || exit 1"]
      timeout     = 5
      retries     = 3
      interval    = 30
      startPeriod = 20
    }
    alb_health_check = [{
      timeout             = 5
      healthy_threshold   = 5
      unhealthy_threshold = 2
      interval            = 30
      matcher             = "200"
      path                = "/health"
    }]
  }
}
