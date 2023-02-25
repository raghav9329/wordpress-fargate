[
  {
    "name": "${task_definition_name}",
    "image": "${app_image}",
    "essential": true,
    "cpu": ${fargate_cpu
    },
    "memory": ${fargate_memory
    },
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_path}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "ecs-stream"
      }
    },
    "portMappings": [
      {
        "containerPort": ${app_port
        },
        "hostPort": ${app_port
        }
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/var/www/html",
        "sourceVolume": "${volume_name}"
      }
    ],
    "environment": [
      {
        "name": "WORDPRESS_DB_HOST",
        "value": "${rds_endpoint}"
      },
      {
        "name": "WORDPRESS_DB_NAME",
        "value": "${db_name}"
      },
      {
        "name": "WORDPRESS_DB_USER",
        "value": "${db_username}"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD",
        "value": "${db_password}"
      },
      {
        "name": "EFS_MOUNT_POINT",
        "value": "${container_file_system_local_mount_path}"
      }
    ]
  }
]