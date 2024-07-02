resource "aws_instance" "webserver1" {
    ami = var.ami_id
    instance_type = var.instance_ID_value
    key_name = var.key_value
    subnet_id = aws_subnet.pub_sub1.id
    user_data = file("userdata.sh")
  
}
resource "aws_instance" "webserver2" {
    ami = var.ami_id
    instance_type = var.instance_ID_value
    key_name = var.key_value
    subnet_id = aws_subnet.pub_sub2.id
    user_data = file("userdata1.sh")
}    