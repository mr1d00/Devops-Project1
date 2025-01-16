provider "aws" {
  region = "ap-south-1"  # Specify your desired AWS region
}

# Connect to an existing security group by its ID
data "aws_security_group" "existing_sg" {
  id = "sg-0a5838fc41591748d"  # Replace with the ID of your existing security group
}

# Reference your custom VPC by name
data "aws_vpc" "custom-vpc" {
  filter {
    name   = "tag:Name"
    values = ["Devops-project-mridul-vpc"]  # Replace with the name of your custom VPC
  }
}

# Reference your custom subnets within the custom VPC
data "aws_subnets" "custom_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.custom-vpc.id]
  }
}

# Ensure there is at least one subnet available
resource "null_resource" "validate_subnets" {
  provisioner "local-exec" {
    command = "echo ${length(data.aws_subnets.custom_subnets.ids)} subnets found"
  }

  depends_on = [data.aws_subnets.custom_subnets]
}

# Provision the EC2 instance
resource "aws_instance" "docker_instance" {
  ami           = "ami-07b69f62c1d38b012"  # Amazon Linux 2 AMI (use the correct AMI ID for your region)
  instance_type = "t2.micro"               # Choose the appropriate instance type
  key_name      = "Devops-project-mridul-key"            # Replace with your SSH key name

  # Use the existing security group
  security_groups = [data.aws_security_group.existing_sg.id]

  # Choose the first subnet from the fetched subnets
  subnet_id = data.aws_subnets.custom_subnets.ids[0]

  # Use user data to install Docker
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable docker
              yum install docker -y
              service docker start
              usermod -a -G docker ec2-user
              EOF

  # Associate public IP address
  associate_public_ip_address = true

  # Add tags to the instance
  tags = {
    Name = "Devops-project-mridul-instance"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  value = aws_instance.docker_instance.public_ip
}

