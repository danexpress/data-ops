data "aws_s3_bucket" "existing" {
  count = var.use_existing_bucket ? 1 : 0
  bucket = var.existing_bucket_name 
}

locals {
    bucket_name = var.use_existing_bucket ? var.existing_bucket_name : "${var.project_name}-raw-data"
}

resource "null_resource" "empty_s3_bucket"{
    triggers = {
        bucket_name = local.bucket_name
    }

    provisioner "local-exec" {
        command = "aws s3 rm s3://${local.bucket_name} --recursive"
    }

    depends_on = [ aws_s3_bucket.raw_data ]
}

resource "aws_s3_bucket" "raw_data" {
    bucket = "${var.project_name}-raw-data"
    force_destroy = true

    tags = {
        Name        = "${var.project_name}-raw-data"
        Environment = "dev"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "raw_data" {
    bucket = aws_s3_bucket.raw_data.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_data" {
    bucket = aws_s3_bucket.raw_data.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_object" "temperature_data"{
    bucket = aws_s3_bucket.raw_data.id
    key    = "temperature_data.csv"
    source = "data/temperature_data.csv"
    content_type = "text/csv"
}


#Glue
resource "aws_iam_role" "glue_role" {
    name = "AWSGlueServiceRole-dml-temperature-analysis"
    force_detach_policies = true

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    service = "glue.amazonaws.com"
                }
            }]
    })
    lifecycle {
      create_before_destroy = true
    }
  
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
    role       = aws_iam_role.glue_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_s3_access" {
    role       = aws_iam_role.glue_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#Glue Resources
# Database
resource "aws_glue_catalog_database" "main" {
    name = "dml-temperature-analysis-catalog"

    create_table_default_permission {
      permissions = ["SELECT"]
      principal {
        data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
      }
    }
    lifecycle {
      create_before_destroy = true
    }
}