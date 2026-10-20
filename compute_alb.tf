data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_lb" "external_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.app_public_a.id, aws_subnet.app_public_b.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-launch-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-USERDATA
              #!/bin/bash
              dnf update -y
              dnf install -y httpd postgresql15 nc
              systemctl enable --now httpd

              # Ensure Apache serves an immediate 200 OK
              echo "<h1>Multi-Tier VPC Architecture Status</h1><p>Web server online on \$(hostname -f)</p>" > /var/www/html/index.html

              # Test RDS across VPC peering and append result
              RDS_HOST="${aws_db_instance.postgres.address}"
              if nc -zvw3 "\$RDS_HOST" 5432 2>&1; then
                echo "<p style='color:green;'><strong>RDS Peering Test (Port 5432):</strong> Connected successfully to \$RDS_HOST</p>" >> /var/www/html/index.html
              else
                echo "<p style='color:red;'><strong>RDS Peering Test (Port 5432):</strong> Connection failed to \$RDS_HOST</p>" >> /var/www/html/index.html
              fi
              USERDATA
  )
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "app-asg"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.app_public_a.id]
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}
