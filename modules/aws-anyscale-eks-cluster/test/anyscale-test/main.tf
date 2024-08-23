# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale AWS EKS Resources
#   This template creates EKS resources for Anyscale
#   Requires:
#     - VPC
#     - Security Group
#     - IAM Roles
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # azs = slice(data.aws_availability_zones.available.names, 0, 3)

  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Create resources for EKS TF Module
#   Creates a VPC
#   Creates a Security Group
#   Creates IAM Roles
# ---------------------------------------------------------------------------------------------------------------------
locals {
  public_subnets  = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
  private_subnets = ["172.24.20.0/24", "172.24.21.0/24", "172.24.22.0/24"]
}
module "eks_vpc" {
  source = "../../../aws-anyscale-vpc"

  anyscale_vpc_name = "anyscale-tftest-eks"
  cidr_block        = "172.24.0.0/16"

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
}
locals {
  # Because subnet ID may not be known at plan time, we cannot use it as a key
  anyscale_subnet_count = length(local.private_subnets)
}

module "eks_securitygroup" {
  source = "../../../aws-anyscale-securitygroups"

  vpc_id = module.eks_vpc.vpc_id

  security_group_name = "anyscale-tftest-eks"
}

module "eks_iam_roles" {
  source = "../../../aws-anyscale-iam"

  module_enabled                       = true
  create_anyscale_access_role          = false
  create_cluster_node_instance_profile = false
  create_iam_s3_policy                 = false

  create_anyscale_eks_cluster_role = true
  anyscale_eks_cluster_role_name   = "anyscale-tftest-eks-cluster-role"
  create_anyscale_eks_node_role    = true
  anyscale_eks_node_role_name      = "anyscale-tftest-eks-node-role"

  create_eks_ebs_csi_driver_role = true
  eks_ebs_csi_role_name          = "anyscale-tftest-eks-ebs-csi-role"
  anyscale_eks_cluster_oidc_arn  = module.kitchen_sink.eks_cluster_oidc_provider_arn
  anyscale_eks_cluster_oidc_url  = module.kitchen_sink.eks_cluster_oidc_provider_url

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create an EKS Resource with no optional parameters
#   Should be executed in us-east-2
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source = "../.."

  module_enabled = true

  anyscale_subnet_ids   = module.eks_vpc.private_subnet_ids
  anyscale_subnet_count = local.anyscale_subnet_count
  eks_role_arn          = module.eks_iam_roles.iam_anyscale_eks_cluster_role_arn

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Use all params and build an EKS Resource
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#trivy:ignore:avd-aws-0065:KMS Key is for testing purposes only
resource "aws_kms_key" "anyscale_kms_eks_cluster_key" {
  #checkov:skip=CKV_AWS_7:This is a test key
  description             = "TFTest - KitchenSink - EKS Cluster Encryption KMS Key"
  enable_key_rotation     = false
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EKS Cluster to Use the Key"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService"    = "eks.${data.aws_region.current.name}.amazonaws.com"
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "Allow Nodes to Use the Key"
        Effect = "Allow"
        Principal = {
          AWS = module.eks_iam_roles.iam_anyscale_eks_node_role_arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.full_tags
}

resource "aws_kms_alias" "anyscale_kms_eks_cluster_key" {
  name          = "alias/tftest-kitchensink-eks-cluster-encryption-key"
  target_key_id = aws_kms_key.anyscale_kms_eks_cluster_key.key_id
}

# Example of providing add-on configuration
locals {
  coredns_config = jsonencode({
    affinity = {
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [
            {
              matchExpressions = [
                {
                  key      = "node-type"
                  operator = "In"
                  values   = ["management"]
                }
              ]
            }
          ]
        }
      }
    },
    nodeSelector = {
      "node-type" = "management"
    },
    tolerations = [
      {
        key      = "CriticalAddonsOnly"
        operator = "Exists"
      },
      {
        effect = "NoSchedule"
        key    = "node-role.kubernetes.io/control-plane"
      }
    ],
    replicaCount = 2
  })
}

module "kitchen_sink" {
  source = "../.."

  module_enabled = true

  anyscale_eks_name             = "anyscale-tftest-kitchensink-eks"
  anyscale_subnet_ids           = module.eks_vpc.private_subnet_ids
  anyscale_subnet_count         = local.anyscale_subnet_count
  additional_security_group_ids = [module.eks_securitygroup.security_group_id]
  eks_role_arn                  = module.eks_iam_roles.iam_anyscale_eks_cluster_role_arn

  kubernetes_version               = "1.30"
  enabled_cluster_log_types        = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
  eks_endpoint_private_access      = false
  eks_endpoint_public_access       = true
  eks_endpoint_public_access_cidrs = var.public_access_cidrs

  eks_cluster_encryption_config_kms_key_arn = aws_kms_key.anyscale_kms_eks_cluster_key.arn

  eks_addons = [
    {
      addon_name           = "coredns"
      addon_version        = "v1.11.1-eksbuild.8"
      configuration_values = local.coredns_config
    }
  ]
  eks_addons_depends_on = module.eks_node_groups

  tags = local.full_tags
}

module "eks_node_groups" {
  source = "../../../aws-anyscale-eks-nodegroups"

  module_enabled = true

  eks_node_role_arn = module.eks_iam_roles.iam_anyscale_eks_node_role_arn
  eks_cluster_name  = module.kitchen_sink.eks_cluster_name
  subnet_ids        = module.eks_vpc.public_subnet_ids

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../.."

  module_enabled = false
}
