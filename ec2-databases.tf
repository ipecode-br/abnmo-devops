# Database configurations
locals {
  database_configs = {
    development = {
      subnet_id   = aws_subnet.public_subnet_a.id
      db_name     = "abnmo_dev"
      db_user     = "abnmo_dev"
      db_password = var.dev_db_password
    }
    homolog = {
      subnet_id   = aws_subnet.public_subnet_b.id
      db_name     = "abnmo_homolog"
      db_user     = "abnmo_homolog"
      db_password = var.homolog_db_password
    }
    production = {
      subnet_id   = aws_subnet.public_subnet_a.id
      db_name     = "abnmo_prod"
      db_user     = "abnmo_admin"
      db_password = var.prod_db_password
    }
  }
}

# Database instances for each environment
resource "aws_instance" "database" {
  for_each = var.database_environments

  ami                    = "ami-0c614dee691cbbf37" # Amazon Linux 2
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  subnet_id              = local.database_configs[each.key].subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name

  user_data = base64encode(templatefile("${path.module}/scripts/init-database.sh", {
    db_name           = local.database_configs[each.key].db_name
    db_user           = local.database_configs[each.key].db_user
    db_password       = local.database_configs[each.key].db_password
    db_admin_user     = var.db_admin_user
    db_admin_password = var.db_admin_password
    root_password     = var.mysql_root_password
  }))

  tags = {
    Name        = "${var.project_name}-database-${each.key}"
    Environment = each.key
    Projeto     = var.project_name
  }
}

# Elastic IPs for stable database endpoints
resource "aws_eip" "database_eip" {
  for_each = var.database_environments

  domain   = "vpc"
  instance = aws_instance.database[each.key].id

  tags = {
    Name        = "${var.project_name}-database-${each.key}-eip"
    Environment = each.key
  }
}

# Wait for instances to be ready and database setup to complete
resource "null_resource" "wait_for_database" {
  for_each = var.database_environments

  depends_on = [aws_instance.database]

  provisioner "local-exec" {
    command = <<EOT
    echo "Waiting for database ${each.key} instance to be ready..."
    aws ec2 wait instance-status-ok --instance-ids ${aws_instance.database[each.key].id} --region us-east-1
    echo "${title(each.key)} database is ready at ${aws_eip.database_eip[each.key].public_ip}"
    EOT
  }
}
