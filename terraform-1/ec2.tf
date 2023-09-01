# Deploy EC2 Instances

resource "aws_instance" "instance1" {
  ami                         = "ami-0b0dcb5067f052a63"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  vpc_security_group_ids      = [aws_security_group.publicsg.id]
  subnet_id                   = aws_subnet.public1.id
  associate_public_ip_address = true
  key_name = "tf_key"
  user_data                   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>First instance successfully deployed</h1></body></html>" > /var/www/html/index.html
        EOF

  tags = {
    Name = "ec2instance1"
  }
}

resource "aws_instance" "instance2" {
  ami                         = "ami-0b0dcb5067f052a63"
  instance_type               = "t2.micro"
  key_name = "tf_key"
  availability_zone           = "us-east-1b"
  vpc_security_group_ids      = [aws_security_group.publicsg.id]
  subnet_id                   = aws_subnet.public2.id
  associate_public_ip_address = true
  user_data                   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>Second instance successfully deployed</h1></body></html>" > /var/www/html/index.html
        EOF

  tags = {
    Name = "ec2instance2"
  }
}

#creating an key pair

resource "aws_key_pair" "tf_key" {
  key_name   = "tf_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#creating an local file to save the key details

resource "local_file" "tf-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}