source "amazon-ebs" "win2022" {
  region        = var.region
  instance_type = var.instance_type
  ami_name      = var.ami_name
  ami_users     = var.share_ami_to_these_accounts
  encrypt_boot  = true
  kms_key_id    = "alias/ami_kms_key"

  source_ami_filter {
    filters = {
      name                = var.source_ami_name
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  ami_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Another EBS Volume if required
  # ami_block_device_mappings {
  #   device_name           = "/dev/xvdb"
  #   volume_size           = 30
  #   volume_type           = "gp3"
  #   delete_on_termination = true
  # }

  # Required connect to the instance via winrm
  user_data_file   = "packer/windows-2022-server/scripts/winrm_bootstrap.txt"
  communicator     = "winrm"
  force_deregister = true
  winrm_username   = "Administrator"
  winrm_insecure   = true
  winrm_use_ssl    = true

  # Enforce IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  imds_support = "v2.0"

  # Create Temporary IAM Instance Profile for SSM and S3 interactions
  temporary_iam_instance_profile_policy_document {
    Version = "2012-10-17"
    Statement {
      Effect = "Allow"
      Action = [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply",
        "s3:Get*",
        "s3:List*",
        "s3:Describe*",
        "s3-object-lambda:Get*",
        "s3-object-lambda:List*"
      ]
      Resource = [
        "*"
      ]
    }
  }

  tags = {
    "created_by" = "packer"
    "os"         = "win2022-server"
    "created_at" = timestamp()
  }
}

build {
  name    = "win2022"
  sources = ["source.amazon-ebs.win2022"]

  provisioner "powershell" {
    script = "packer/windows-2022-server/scripts/build.ps1"
  }

  provisioner "powershell" {
    script = "packer/windows-2022-server/scripts/harden.ps1"
  }
}
