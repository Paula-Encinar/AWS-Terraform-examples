[
  {
    "name": "${container_name}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "essential": true,
    "networkMode": "awsvpc",
    "volumesFrom": [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_logs_group}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "protocol": "tcp",
        "hostPort": ${host_port}
      }
    ],
    "environment": [
    {
      "name": "BACKEND_URL",
      "value": "${backend_url}"
    },
    {
      "name": "CLOUDFRONT_URL",
      "value": "https://d3ui2hintozl0k.cloudfront.net"
    },
    {
      "name": "ENVIRONMENT",
      "value": "${long_environment}"
    },
    {
      "name": "EXPORTS_URL",
      "value": "https://exports.secure-servelegal.co.uk"
    }
    ],
    "secrets": [
      {
        "name": "AWS_REGION",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:avs_aws_credentials-Ldy7zR:region::"
      },
      { "name": "COGNITO_USER_POOL_ID",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:avs_config_production-yRTxRO:cognito_user_pool_id::"
      },
      { "name": "COGNITO_USER_POOL_WEB_CLIENT_ID",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:avs_config_production-yRTxRO:cognito_user_pool_web_client_id::"
      },
      { "name": "GOOGLE_MAPS_KEY",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:google-CVbfcj:maps_key::"
      },
      { "name": "FIREBASE_KEY",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:firebase_front_end_production-aW6X3T"
      },
      { "name": "COGNITO_IDENTITY_POOL_ID",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:cognito_identity_pool_id_prod-QeOmRt"
      },
      { "name": "PINPOINT_APP_REGION",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:pinpoint_app_region-4zPmug"
      },
      { "name": "PINPOINT_APP_ID",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:pinpoint_app_id_prod-LWxZWV"
      },
      { "name": "SENTRY_AUTH_TOKEN",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:sentry_configuration-kOCCRZ"
      },
      { "name": "SENTRY_DSN",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:sentry_configuration-kOCCRZ"
      },
      { "name": "CONFIGCAT_APIKEY",
        "valueFrom": "arn:aws:secretsmanager:eu-west-2:780679956791:secret:production/configcat-xgbdzG"
      }
    ]
  }
]
