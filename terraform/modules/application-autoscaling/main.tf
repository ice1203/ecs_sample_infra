# application autoscaling
# IAM Role
resource "aws_iam_service_linked_role" "ecs_service_autoscaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
}
# 既にサービスリンクロールが作成されている場合は以下のように記述
#data "aws_iam_role" "ecs_service_autoscaling" {
#  name = "AWSServiceRoleForApplicationAutoScaling_ECSService"
#}

## application autoscaling target
resource "aws_appautoscaling_target" "ecs_service" {
  service_namespace = "ecs"

  # 紐付けたいECSのサービスを設定
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  # オートスケーリングを実行するサービスリンクロールArn
  role_arn = aws_iam_service_linked_role.ecs_service_autoscaling.arn
  # 既にサービスリンクロールが作成されている場合は以下のように記述
  #role_arn           = data.aws_iam_role.ecs_service_autoscaling.arn

  # オートスケーリングさせるECSタスクの最小値と最大値を指定
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

# ターゲット追跡スケーリングポリシー（CPU利用率）
resource "aws_appautoscaling_policy" "ecs_cpu_target" {
  name               = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# ターゲット追跡スケーリングポリシー（Memory利用率）
resource "aws_appautoscaling_policy" "ecs_memory_target" {
  name               = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-memory-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }

}
