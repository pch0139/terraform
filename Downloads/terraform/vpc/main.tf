# VPC 생성
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name  = "${var.name}_vpc"
    Owner = var.tag
  }
}
# 퍼블릭 서브넷 생성
resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.public_subnets
  availability_zone = each.value["az"]
  cidr_block        = each.value["cidr"]
  tags = {
    Name  = "${var.name}_${each.key}"
    Owner = var.tag
  }
}
# 프라이빗 서브넷 생성
resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.private_subnets
  availability_zone = each.value["az"]
  cidr_block        = each.value["cidr"]
  tags = {
    Name  = "${var.name}_${each.key}"
    Owner = var.tag
  }
}
#인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name  = "${var.name}_igw"
    Owner = var.tag
  }
}
# NAT 게이트웨이 생성
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_a"].id
  tags = {
    Name  = "${var.name}_nat_gw"
    Owner = var.tag
  }
  depends_on = [aws_internet_gateway.igw]
}
# NAT 게이트웨이에 연결 할 퍼블릭 IP 생성
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "${var.name}_nat_eip"
    Owner = var.tag
  }
}
#퍼블릭 라우팅 테이블 생성"
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name  = "${var.name}_public_route_table"
    Owner = var.tag
  }
}
# 프라비잇 라우팅 테이블 생성
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name  = "${var.name}_private_route_table"
    Owner = var.tag
  }
}
# 퍼블릭 서브넷에 퍼블릭 라우팅 연결
resource "aws_route_table_association" "public_route_table_association" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_route_table.id
}
# 프라비잇 서브넷에 프라이빗 라우팅 연결
resource "aws_route_table_association" "private_route_table_association" {
  for_each       = var.private_subnets
  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_route_table.id
}
