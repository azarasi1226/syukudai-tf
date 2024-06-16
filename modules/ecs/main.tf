locals {
    container_name = "${var.resource_prefix}-ecs-sample"
}

# 各サービスを管理するECSクラスター
resource "aws_ecs_cluster" "this" {
  name = "${var.resource_prefix}-cluster"
}

#ECR                     
resource "aws_ecr_repository" "this" {
  name = "${var.resource_prefix}-ecr"
  //脆弱性のスキャン
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECSタスク定義
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.resource_prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = templatefile("${path.module}/task.json", {
    service_name = local.container_name,
    image_url    = aws_ecr_repository.this.repository_url
  })

  task_role_arn      = module.ecs_task_role.iam_role_arn
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

# ECSサービス
resource "aws_ecs_service" "this" {
  name             = "${var.resource_prefix}-ecs-service"
  cluster          = aws_ecs_cluster.this.arn
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = 3
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  //ロードバランサーからのヘルスチェック猶予秒数
  //この時間が短いとTaskの起動に時間がかかった場合、起動と停止の無限ループに陥る
  //長すぎてもスケールを阻害するので1分とする
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.frontend_sg.security_group_id]
    subnets          = var.subnet_ids
  }

  load_balancer {
    target_group_arn = module.alb.blue_targetgroup_arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}