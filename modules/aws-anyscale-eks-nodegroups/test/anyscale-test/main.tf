# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale AWS EKS Node Group Resources
#   This template creates EKS Node Group resources for Anyscale
#   Requires:
#     - VPC
#     - Security Group
#     - IAM Roles
#     - EKS Cluster
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

  tags = local.full_tags
}
locals {
  # Because subnet ID may not be known at plan time, we cannot use it as a key
  anyscale_subnet_count = length(local.private_subnets)
}

module "eks_securitygroup" {
  source = "../../../aws-anyscale-securitygroups"

  vpc_id = module.eks_vpc.vpc_id

  security_group_name = "anyscale-tftest-eks"

  tags = local.full_tags
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

  tags = local.full_tags
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

module "eks_cluster" {
  source = "../../../aws-anyscale-eks-cluster"

  module_enabled = true

  anyscale_subnet_ids        = module.eks_vpc.public_subnet_ids
  anyscale_subnet_count      = local.anyscale_subnet_count
  anyscale_security_group_id = module.eks_securitygroup.security_group_id
  eks_role_arn               = module.eks_iam_roles.iam_anyscale_eks_cluster_role_arn

  eks_addons = [
    {
      addon_name           = "coredns"
      addon_version        = "v1.11.1-eksbuild.8"
      configuration_values = local.coredns_config
    }
  ]
  eks_addons_depends_on = module.all_defaults

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create EKS Node Group with no optional parameters
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source = "../../"

  module_enabled = true

  anyscale_security_group_id   = module.eks_securitygroup.security_group_id
  kubernetes_security_group_id = module.eks_cluster.cluster_managed_security_group_id

  eks_node_role_arn = module.eks_iam_roles.iam_anyscale_eks_node_role_arn
  eks_cluster_name  = module.eks_cluster.eks_cluster_name
  subnet_ids        = module.eks_vpc.public_subnet_ids

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Use all params and build EKS Node Groups
# ---------------------------------------------------------------------------------------------------------------------
module "kitchen_sink" {
  source = "../.."

  module_enabled = true

  launch_template_name = "anyscale-tftest-eks-launch-template"

  anyscale_security_group_id   = module.eks_securitygroup.security_group_id
  kubernetes_security_group_id = module.eks_cluster.cluster_managed_security_group_id

  eks_node_role_arn = module.eks_iam_roles.iam_anyscale_eks_node_role_arn
  eks_cluster_name  = module.eks_cluster.eks_cluster_name
  subnet_ids        = module.eks_vpc.public_subnet_ids

  node_group_disk_size = 750

  create_eks_management_node_group = true
  eks_management_node_group_config = {
    name           = "eks-management"
    instance_types = ["t3.large"]
    capacity_type  = "ON_DEMAND"
    labels = {
      "node-type" = "management"
      "env"       = "test"
    }
    tags = {
      "node-type" = "management",
      "test"      = "kitchen-sink"
    }
    scaling_config = {
      desired_size = 2
      max_size     = 5
      min_size     = 1
    }
    update_config = {
      max_unavailable_percentage = 66
    }
    taints = [
      {
        key    = "node-type"
        value  = "management"
        effect = "PREFER_NO_SCHEDULE"
      }
    ]
  }

  create_anyscale_node_groups = true
  eks_anyscale_node_groups = [
    {
      name           = "eks-anyscale"
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels = {
        "node-type" = "anyscale"
        "env"       = "test"
      }
      tags = {
        "node-type" = "anyscale",
        "test"      = "kitchen-sink"
      }
      scaling_config = {
        desired_size = 2
        max_size     = 5
        min_size     = 1
      }
      update_config = {
        max_unavailable_percentage = 66
      }
      taints = [
        {
          key    = "node-type"
          value  = "anyscale"
          effect = "NO_SCHEDULE"
        }
      ]
    },
    {
      name           = "eks-anyscale-2"
      instance_types = ["m5.xlarge"]
      capacity_type  = "SPOT"
      labels = {
        "node-type" = "anyscale"
        "env"       = "test"
      }
      tags = {
        "node-type" = "anyscale",
        "test"      = "kitchen-sink"
      }
      scaling_config = {
        desired_size = 0
        max_size     = 5
        min_size     = 0
      }
      taints = []
    }
  ]

  tags = local.full_tags

}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../.."

  eks_node_role_arn = module.eks_iam_roles.iam_anyscale_eks_node_role_arn
  eks_cluster_name  = module.eks_cluster.eks_cluster_name
  subnet_ids        = module.eks_vpc.public_subnet_ids

  module_enabled = false
}
