data "aws_secretsmanager_secret" "jenkins" {
  name = "${var.project_name}-jenkins"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_inline_policy" {
  name = "my_inline_policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:Get*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:RunInstances",
          "ec2:CreateTags"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:ec2:us-east-2:*:instance/*",
          "arn:aws:ec2:us-east-2:*:volume/*"
        ]
        Condition = {
          StringEquals = { "aws:RequestTag/Project" = var.project_name }
        }
      },
      {
        Action   = ["ec2:RunInstances"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:ec2:us-east-2:*:image/*",
          "arn:aws:ec2:us-east-2:*:subnet/*",
          "arn:aws:ec2:us-east-2:*:key-pair/*",
          "arn:aws:ec2:us-east-2:*:security-group/*",
          "arn:aws:ec2:us-east-2:*:network-interface/*"
        ]
      },
      {
        Action   = ["ec2:TerminateInstances"]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project" = var.project_name
            "aws:ResourceTag/Role"    = "jenkins-slave"
          }
        }
      },
      {
        Action   = ["secretsmanager:GetSecretValue"]
        Effect   = "Allow"
        Resource = data.aws_secretsmanager_secret.jenkins.arn
      },
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::aws-task6-eks",
          "arn:aws:s3:::aws-task6-eks/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}
