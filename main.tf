resource "aws_vpc" "MyVPC" {
    cidr_block = var.cidr_vpc  
}

resource "aws_subnet" "pub_sub1" {
    vpc_id = aws_vpc.MyVPC.id
    cidr_block = var.cidr_sub1
    availability_zone = var.zone1
    map_public_ip_on_launch = true
  
}
resource "aws_subnet" "pub_sub2" {
    vpc_id = aws_vpc.MyVPC.id
    cidr_block = var.cidr_sub2
    availability_zone = var.zone2
    map_public_ip_on_launch = true
  
}
resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.MyVPC.id  
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.MyVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }


}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.pub_sub1.id
    route_table_id = aws_route_table.RT.id
  
}
resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.pub_sub2.id
    route_table_id = aws_route_table.RT.id
  
}

resource "aws_security_group" "MySG" {
    name = "websg"
    vpc_id = aws_vpc.MyVPC.id

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_s3_bucket" "mybucket" {
    bucket = "surajterraformproject2022"
  
}
resource "aws_lb" "myalb" {
    name = "myalb"
    internal = false
    load_balancer_type = "application"

    security_groups = [aws_security_group.MySG.id]
    subnets         = [aws_subnet.pub_sub1.id, aws_subnet.pub_sub2.id]

    tags = {
        name = "web"
    }
  
}

resource "aws_lb_target_group" "tg" {
    name = "mytg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.MyVPC.id

    health_check {
      path = "/"
      port = "traffic-port"
    }
  
}

resource "aws_lb_target_group_attachment" "attach1" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id = aws_instance.webserver1.id
    port = 80
  
}

resource "aws_lb_target_group_attachment" "attach2" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id = aws_instance.webserver2.id
  
}
resource "aws_lb_listener" "listner" {
    load_balancer_arn = aws_lb.myalb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      target_group_arn = aws_lb_target_group.tg.arn
      type = "forward"
    }
  
}

output "loadbalancerdns" {
    value = aws_lb.myalb.dns_name
  
}