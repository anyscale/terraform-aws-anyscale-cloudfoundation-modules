# ---------------------------
# EKS Service Cluster Role
#   - This role is used by the EKS service to manage the EKS cluster
# ---------------------------
locals {
  create_eks_cluster_role = var.create_anyscale_eks_cluster_role && var.module_enabled

  eks_cluster_role_desc   = var.anyscale_eks_cluster_role_description != null ? var.anyscale_eks_cluster_role_description : var.anyscale_cloud_id != null ? "Anyscale EKS Cluster Role for cloud ${var.anyscale_cloud_id} in region ${local.region_name}" : "Anyscale EKS cluster role"
  eks_cluster_role_name   = try(var.anyscale_eks_cluster_role_name, null)
  eks_cluster_role_prefix = local.eks_cluster_role_name != null ? null : var.anyscale_eks_cluster_role_name_prefix != null ? var.anyscale_eks_cluster_role_name_prefix : "anyscale-eks-cluster-"

  eks_cluster_autoscaler_policy_name   = try(var.anyscale_eks_cluster_autoscaler_policy_name, null)
  eks_cluster_autoscaler_policy_prefix = local.eks_cluster_autoscaler_policy_name != null ? null : var.anyscale_eks_cluster_autoscaler_policy_prefix != null ? var.anyscale_eks_cluster_autoscaler_policy_prefix : "anyscale-eks-cluster-autoscaler-"

}
resource "aws_iam_role" "anyscale_eks_cluster_role" {
  count = local.create_eks_cluster_role ? 1 : 0

  name        = local.eks_cluster_role_name
  name_prefix = local.eks_cluster_role_prefix
  path        = var.anyscale_eks_cluster_role_path
  description = local.eks_cluster_role_desc

  permissions_boundary = var.anyscale_eks_cluster_role_permissions_boundary_arn
  assume_role_policy   = one(data.aws_iam_policy_document.eks_cluster_assume_role[*].json)
}

# EKS Service Cluster Policy
#   Cluster Autoscaler
#   https://github.com/kubernetes/autoscaler/blob/055e2bfc04ccf1e4dae2ff2ca0f55e0074fb17fa/cluster-autoscaler/cloudprovider/aws/README.md#iam-policy
resource "aws_iam_policy" "anyscale_iam_custom_autoscaler_policy" {
  count = local.create_eks_cluster_role ? 1 : 0

  name        = local.eks_cluster_autoscaler_policy_name
  name_prefix = local.eks_cluster_autoscaler_policy_prefix
  path        = var.anyscale_eks_cluster_autoscaler_policy_path
  description = var.anyscale_eks_cluster_autoscaler_policy_description
  policy      = one(data.aws_iam_policy_document.eks_cluster_autoscaling_policy[*].json)

  tags = var.tags
}

# EKS Service Cluster Policy Attachments
resource "aws_iam_role_policy_attachment" "anyscale_eks_cluster_amazoneksclusterpolicy_attach" {
  count = local.create_eks_cluster_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.anyscale_eks_cluster_role[0].name
}

resource "aws_iam_role_policy_attachment" "anyscale_eks_cluster_amazoneksvpcresourcecontroller_attach" {
  count = local.create_eks_cluster_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.anyscale_eks_cluster_role[0].name
}

resource "aws_iam_role_policy_attachment" "anyscale_eks_cluster_amazonekscnipolicy_attach" {
  count = local.create_eks_cluster_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.anyscale_eks_cluster_role[0].name
}

resource "aws_iam_role_policy_attachment" "anyscale_eks_cluster_autoscaler_policy_attach" {
  count = local.create_eks_cluster_role ? 1 : 0

  role       = aws_iam_role.anyscale_eks_cluster_role[0].name
  policy_arn = aws_iam_policy.anyscale_iam_custom_autoscaler_policy[0].arn
}

# ---------------------------
# EKS Node Role
#   - This role is used by the EKS nodes to join the EKS cluster
# ---------------------------
locals {
  create_eks_node_role = var.create_anyscale_eks_node_role && var.module_enabled

  eks_node_role_desc   = var.anyscale_eks_node_role_description != null ? var.anyscale_eks_node_role_description : var.anyscale_cloud_id != null ? "Anyscale EKS Node Role for cloud ${var.anyscale_cloud_id} in region ${local.region_name}" : "Anyscale EKS node role"
  eks_node_role_name   = try(var.anyscale_eks_node_role_name, null)
  eks_node_role_prefix = local.eks_node_role_name != null ? null : var.anyscale_eks_node_role_name_prefix != null ? var.anyscale_eks_node_role_name_prefix : "anyscale-eks-node-"
}
resource "aws_iam_role" "eks_node_role" {
  count = local.create_eks_node_role ? 1 : 0

  name        = local.eks_node_role_name
  name_prefix = local.eks_node_role_prefix
  path        = var.anyscale_eks_node_role_path
  description = local.eks_node_role_desc

  permissions_boundary = var.anyscale_eks_node_role_permissions_boundary_arn
  assume_role_policy   = one(data.aws_iam_policy_document.eks_node_assume_role[*].json)
}

# EKS Node Policy Attachments
resource "aws_iam_role_policy_attachment" "anyscale_eks_node_amazoneksworkernodepolicy_attach" {
  count = local.create_eks_node_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role[0].name
}

resource "aws_iam_role_policy_attachment" "anyscale_eks_node_amazonekscnipolicy_attach" {
  count = local.create_eks_node_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role[0].name
}

resource "aws_iam_role_policy_attachment" "anyscale_eks_node_amazonec2containerregistryreadonly_attach" {
  count = local.create_eks_node_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role[0].name
}


# ---------------------------
# EKS EBS CSI Driver Role
#   - This role is used by the EKS CSI driver to manage the EKS cluster
# ---------------------------
locals {
  create_eks_csi_driver_role = var.create_eks_ebs_csi_driver_role && var.module_enabled

  eks_ebs_csi_role_desc        = var.eks_ebs_csi_role_description != null ? var.eks_ebs_csi_role_description : var.anyscale_cloud_id != null ? "Anyscale EKS EBS CBI Role for cloud ${var.anyscale_cloud_id} in region ${local.region_name}" : "Anyscale EKS EBS CBI role"
  eks_ebs_csi_role_name        = try(var.eks_ebs_csi_role_name, null)
  eks_ebs_csi_role_name_prefix = local.eks_ebs_csi_role_name != null ? null : var.eks_ebs_csi_role_name_prefix != null ? var.eks_ebs_csi_role_name_prefix : "anyscale-eks-ebs-cbi-"
}

resource "aws_iam_role" "anyscale_eks_csi_driver_role" {
  count = local.create_eks_csi_driver_role ? 1 : 0

  name        = local.eks_ebs_csi_role_name
  name_prefix = local.eks_ebs_csi_role_name_prefix
  path        = var.eks_ebs_csi_role_path
  description = local.eks_ebs_csi_role_desc

  permissions_boundary = var.eks_ebs_csi_role_permissions_boundary_arn
  assume_role_policy   = one(data.aws_iam_policy_document.eks_ebs_csi_driver_assume_role[*].json)
}

# EKS EBS CSI Driver Policy Attachments
resource "aws_iam_role_policy_attachment" "anyscale_eks_csi_driver_amazonebscsidriver_attach" {
  count = local.create_eks_csi_driver_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.anyscale_eks_csi_driver_role[0].name
}
