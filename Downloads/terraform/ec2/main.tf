data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["137112412989"] # Canonical

}

data "aws_key_pair" "pchoon" {

  filter {
    name   = "tag:Owner"
    values = ["pchoon@mz.co.kr"]
  }
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.al2023.id
  instance_type        = "t3.micro"
  subnet_id            = local.private_subnet_ids[0]
  security_groups      = [aws_security_group.default_sg.id]
  key_name             = data.aws_key_pair.pchoon.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
if [[ `systemctl is-active amazon-ssm-agent.service` != "active" ]]
then
	systemctl start amazon-ssm-agent.service
fi
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
alias k=kubectl
complete -o default -F __start_kubectl k
yum install -y yum-utils shadow-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install terraform
yum -y install git
EOF

  tags = {
    Name  = "${var.name}_bastion"
    Owner = var.tag
  }
}

resource "aws_security_group" "default_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = local.vpc_id

  tags = {
    Name  = "${var.name}_sg"
    Owner = var.tag
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.default_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.name}_ec2_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = {
    Name  = "${var.name}_ec2_role"
    Owner = var.tag
  }
}

resource "aws_iam_role_policy_attachment" "ec2_role_AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name}_ec2_profile"
  role = aws_iam_role.ec2_role.name
}