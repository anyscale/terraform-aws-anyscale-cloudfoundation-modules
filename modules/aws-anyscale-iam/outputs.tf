# --------------------------------
# Anyscale Access Role & Policies
# --------------------------------
output "iam_anyscale_access_role_arn" {
  description = "ARN of Anyscale access IAM role"
  value       = try(aws_iam_role.anyscale_access_role[0].arn, "")
}

output "iam_anyscale_access_role_name" {
  description = "Name of Anyscale access IAM role"
  value       = try(aws_iam_role.anyscale_access_role[0].name, "")
}

output "iam_anyscale_access_role_path" {
  description = "Path of Anyscale access IAM role"
  value       = try(aws_iam_role.anyscale_access_role[0].path, "")
}

output "iam_anyscale_access_role_unique_id" {
  description = "Unique ID of Anyscale access IAM role"
  value       = try(aws_iam_role.anyscale_access_role[0].unique_id, "")
}

# Steady state policy
output "anyscale_steadystate_policy_arn" {
  description = "ARN of Anyscale Steady State IAM policy"
  value       = try(aws_iam_policy.anyscale_steadystate_policy[0].arn, "")
}
output "anyscale_steadystate_policy_name" {
  description = "Name of Anyscale Steady State IAM policy"
  value       = try(aws_iam_policy.anyscale_steadystate_policy[0].name, "")
}
output "anyscale_steadystate_policy_path" {
  description = "Path of Anyscale Steady State IAM policy"
  value       = try(aws_iam_policy.anyscale_steadystate_policy[0].path, "")
}
output "anyscale_steadystate_policy_id" {
  description = "Policy ID of Anyscale Steady State IAM policy"
  value       = try(aws_iam_policy.anyscale_steadystate_policy[0].policy_id, "")
}

# Services v2 policy
output "anyscale_servicesv2_policy_arn" {
  description = "ARN of Anyscale Steady State IAM policy"
  value       = try(aws_iam_policy.anyscale_servicesv2_policy[0].arn, "")
}
output "anyscale_servicesv2_policy_name" {
  description = "Name of Anyscale Steady State IAM policy"
  value       = try(aws_iam_policy.anyscale_servicesv2_policy[0].name, "")
}
output "anyscale_servicesv2_policy_path" {
  description = "Path of Anyscale Steady State IAM policy"
  value       = try(aws_iam_policy.anyscale_servicesv2_policy[0].path, "")
}
output "anyscale_servicesv2_policy_id" {
  description = "Policy ID of Anyscale Steady State IAM policy"
  value       = try(aws_iam_policy.anyscale_servicesv2_policy[0].policy_id, "")
}

# Custom policy
output "anyscale_iam_custom_policy_arn" {
  description = "ARN of Anyscale custom IAM policy"
  value       = try(aws_iam_policy.anyscale_iam_custom_policy[0].arn, "")
}
output "anyscale_iam_custom_policy_name" {
  description = "Name of Anyscale custom IAM policy"
  value       = try(aws_iam_policy.anyscale_iam_custom_policy[0].name, "")
}
output "anyscale_iam_custom_policy_path" {
  description = "Path of Anyscale custom IAM policy"
  value       = try(aws_iam_policy.anyscale_iam_custom_policy[0].path, "")
}
output "anyscale_iam_custom_policy_id" {
  description = "Policy ID of Anyscale custom IAM policy"
  value       = try(aws_iam_policy.anyscale_iam_custom_policy[0].policy_id, "")
}

# --------------------------------------------
# Anyscale Instance Profile Role and Policies
# --------------------------------------------
output "iam_cluster_node_role_arn" {
  description = "ARN OF IAM Role for Anyscale Instance Profile"
  value       = try(aws_iam_role.anyscale_cluster_node_role[0].arn, "")
}

output "iam_cluster_node_instance_profile_role_arn" {
  description = "ARN of IAM instance profile"
  value       = try(aws_iam_instance_profile.anyscale_cluster_node_role[0].arn, "")
}

output "iam_cluster_node_instance_profile_name" {
  description = "Name of IAM instance profile"
  value       = try(aws_iam_instance_profile.anyscale_cluster_node_role[0].name, "")
}

output "iam_cluster_node_instance_profile_id" {
  description = "IAM Instance profile's ID."
  value       = try(aws_iam_instance_profile.anyscale_cluster_node_role[0].id, "")
}

output "iam_cluster_node_instance_profile_path" {
  description = "Path of IAM instance profile"
  value       = try(aws_iam_instance_profile.anyscale_cluster_node_role[0].path, "")
}

# Custom policy
output "anyscale_cluster_node_custom_policy_arn" {
  description = "ARN of Anyscale cluster node custom policy"
  value       = try(aws_iam_policy.anyscale_cluster_node_custom_policy[0].arn, "")
}
output "anyscale_cluster_node_custom_policy_name" {
  description = "Name of Anyscale cluster node custom policy"
  value       = try(aws_iam_policy.anyscale_cluster_node_custom_policy[0].name, "")
}
output "anyscale_cluster_node_custom_policy_path" {
  description = "Path of Anyscale cluster node custom policy"
  value       = try(aws_iam_policy.anyscale_cluster_node_custom_policy[0].path, "")
}
output "anyscale_cluster_node_custom_policy_id" {
  description = "Policy ID of Anyscale cluster node custom policy"
  value       = try(aws_iam_policy.anyscale_cluster_node_custom_policy[0].policy_id, "")
}

# S3 Policy
output "anyscale_iam_s3_policy_arn" {
  description = "ARN of Anyscale IAM S3 policy"
  value       = try(aws_iam_policy.anyscale_s3_access_policy[0].arn, "")
}
output "anyscale_iam_s3_policy_name" {
  description = "Name of Anyscale IAM S3 policy"
  value       = try(aws_iam_policy.anyscale_s3_access_policy[0].name, "")
}
output "anyscale_iam_s3_policy_path" {
  description = "Path of Anyscale IAM S3 policy"
  value       = try(aws_iam_policy.anyscale_s3_access_policy[0].path, "")
}
output "anyscale_iam_s3_policy_id" {
  description = "Policy ID of Anyscale IAM S3 policy"
  value       = try(aws_iam_policy.anyscale_s3_access_policy[0].policy_id, "")
}

# --------------------------------------------
# Anyscale EKS Role and Policies
# --------------------------------------------
# EKS Cluster Role
output "iam_anyscale_eks_cluster_role_arn" {
  description = "ARN of Anyscale EKS cluster IAM role"
  value       = try(aws_iam_role.anyscale_eks_cluster_role[0].arn, "")
}

output "iam_anyscale_eks_cluster_role_name" {
  description = "Name of Anyscale EKS cluster IAM role"
  value       = try(aws_iam_role.anyscale_eks_cluster_role[0].name, "")
}

output "iam_anyscale_eks_cluster_role_path" {
  description = "Path of Anyscale EKS cluster IAM role"
  value       = try(aws_iam_role.anyscale_eks_cluster_role[0].path, "")
}

# EKS Node Role
output "iam_anyscale_eks_node_role_arn" {
  description = "ARN of Anyscale EKS node IAM role"
  value       = try(aws_iam_role.eks_node_role[0].arn, "")
}

output "iam_anyscale_eks_node_role_name" {
  description = "Name of Anyscale EKS node IAM role"
  value       = try(aws_iam_role.eks_node_role[0].name, "")
}

output "iam_anyscale_eks_node_role_path" {
  description = "Path of Anyscale EKS node IAM role"
  value       = try(aws_iam_role.eks_node_role[0].path, "")
}
