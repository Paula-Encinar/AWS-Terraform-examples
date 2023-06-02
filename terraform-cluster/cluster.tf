resource "aws_ecs_cluster" "staging" {
  name = "test-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers_fargate" {
  cluster_name = aws_ecs_cluster.staging.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # default_capacity_provider_strategy {
  #   base              = 2
  #   weight            = 2
  #   capacity_provider = "FARGATE"
  # }
}


resource "aws_ecs_task_definition" "service1" {
  family                   = "dummyapi-staging-second-round"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 512
  memory                   = 1024
  container_definitions = jsonencode([
    {
      name      = "sproutlyapi"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
        }
      ]
    },
  ])

  requires_compatibilities = ["FARGATE"]
  tags = {
    Environment = "staging"
    Application = "dummyapi"
  }
}

resource "aws_ecs_service" "staging" {
  name            = "staging"
  cluster         = aws_ecs_cluster.staging.id
  task_definition = aws_ecs_task_definition.service1.arn
  desired_count   = 4


  capacity_provider_strategy {
    base              = 2 # numero de tareas fijas 
    weight            = 0
    capacity_provider = "FARGATE"
  }

  capacity_provider_strategy {
    base              = 0
    weight            = 1 #porcentaje de tareas que se desplegarán 
    capacity_provider = "FARGATE_SPOT"
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.staging.arn
    container_name   = "sproutlyapi"
    container_port   = 4000
  }

  depends_on = [aws_lb_listener.https_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = {
    Environment = "staging"
    Application = "sproutlyapi"
  }
}