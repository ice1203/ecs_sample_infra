# ecs
## ecs task execution role
data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-taskexec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_add_ecs_taskexecution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## ecs task role
data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_policy" "ecsexec_policy" {
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
      }
   ]
}
EOF
}
#trivy:ignore:AVD-AWS-0057
resource "aws_iam_policy" "awsdistro_policy" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:PutRetentionPolicy",
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets",
                "xray:GetSamplingStatisticSummaries",
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "ssm:GetParameters",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_add_ecsexec_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecsexec_policy.arn
}
resource "aws_iam_role_policy_attachment" "ecs_task_role_add_awsdistro_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.awsdistro_policy.arn
}


## security group for ecs task
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "my_ecs_task" {
  name        = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs"
  description = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs"
  vpc_id      = var.vpc_id
  ingress {
    #description = "Allow traffic from ALB"
    security_groups = [aws_security_group.my_alb.id]
    from_port       = var.docker_container_port
    to_port         = var.docker_container_port
    protocol        = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
## security group for alb
#trivy:ignore:AVD-AWS-0107
resource "aws_security_group" "my_alb" {
  name        = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-alb"
  description = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-alb"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = var.alb_listener_port
    to_port     = var.alb_listener_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.alb_allowed_cidr_blocks
  }
}
#trivy:ignore:AVD-AWS-0053
resource "aws_lb" "my_alb" {
  name                       = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-alb"
  internal                   = false
  security_groups            = [aws_security_group.my_alb.id]
  subnets                    = var.public_subnets
  drop_invalid_header_fields = true
  #access_logs {
  #  bucket  = var.elblog_bucket_name
  #  prefix  = "${var.env_name}-${var.svc_name}-ALB"
  #  enabled = true
  #}
  tags = {
    Name = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-alb"
  }
}

## ALB target group 1
resource "aws_lb_target_group" "my_alb_1" {
  name_prefix          = "webecs"
  port                 = var.docker_container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 15
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "6"
    timeout             = "5"
    unhealthy_threshold = "3"
    healthy_threshold   = "2"
  }
  lifecycle {
    create_before_destroy = true
  }

}

## ALB target group 2
resource "aws_lb_target_group" "my_alb_2" {
  name_prefix          = "webecs"
  port                 = var.docker_container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 15
  health_check {
    path = "/"
    #path                = "/rolldice"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "6"
    timeout             = "5"
    unhealthy_threshold = "3"
    healthy_threshold   = "2"
  }
  lifecycle {
    create_before_destroy = true
  }

}
## ALB listener
#trivy:ignore:AVD-AWS-0054
resource "aws_lb_listener" "my_alb_prod" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = var.alb_listener_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_alb_1.arn
  }

  depends_on = [aws_lb_target_group.my_alb_1]
  lifecycle {
    ignore_changes = [default_action]
  }
}
#trivy:ignore:AVD-AWS-0054
resource "aws_lb_listener" "my_alb_test" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_alb_2.arn
  }

  depends_on = [aws_lb_target_group.my_alb_2]
  lifecycle {
    ignore_changes = [default_action]
  }
}


## cloudwatchlog group
resource "aws_cloudwatch_log_group" "my_ecs_task" {
  name              = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-loggrp"
  retention_in_days = "30"
}

## ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.sys_name}-${var.env_name}-${var.subsys_name}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
