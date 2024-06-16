# ----------------------------------------------------------------------------------------
# 継承元ポリシー(初期でECSタスクにアタッチされるポリシー)
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# タスク実行ポリシー
data "aws_iam_policy_document" "ecs_task_execution" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy]

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup"
    ]
  }
}

# タスク実行ロール
module "ecs_task_execution_role" {
  source = "../iam_role"

  resource_prefix = var.resource_prefix
  usage_name      = "${var.resource_prefix}-task-execution"
  identifier      = "ecs-tasks.amazonaws.com"
  policy          = data.aws_iam_policy_document.ecs_task_execution.json
}

# タスクポリシー
data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup"
    ]
  }
}

# タスクロール
module "ecs_task_role" {
  source = "../iam_role"

  resource_prefix = var.resource_prefix
  usage_name      = "${var.resource_prefix}-task"
  identifier      = "ecs-tasks.amazonaws.com"
  policy          = data.aws_iam_policy_document.ecs_task.json
}

# セキュリティグループ
module "frontend_sg" {
  source = "../security_group"

  resource_prefix = var.resource_prefix
  usage_name      = "frontend"
  vpc_id          = var.vpc_id
  allow_port      = "80"
  allow_cidrs     = ["0.0.0.0/0"]
}