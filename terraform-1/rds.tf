# Relational Database Service Subnet Group
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "dbsubnet"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

# Create RDS Instance
resource "aws_db_instance" "dbinstance" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  identifier             = "dbinstance"
  db_name                = "db"
  username               = "admin"
  password               = "password"
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.id
  vpc_security_group_ids = [aws_security_group.privatesg.id]
  skip_final_snapshot    = true
}