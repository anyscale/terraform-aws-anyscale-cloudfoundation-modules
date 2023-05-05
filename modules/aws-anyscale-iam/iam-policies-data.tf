locals {
  anyscale_cluster_role_arn = try(
    aws_iam_role.anyscale_cluster_node_role[0].arn,
    "arn:aws:iam::${local.account_id}:role/${local.anyscale_cluster_node_role_name}",
    "arn:aws:iam::${local.account_id}:role/${local.anyscale_cluster_node_role_name_prefix}*"
  )
  anyscale_cluster_instance_profile_arn = try(
    aws_iam_instance_profile.anyscale_cluster_node_role[0].arn,
    "arn:aws:iam::${local.account_id}:instance-profile/${local.anyscale_cluster_node_role_name}",
    "arn:aws:iam::${local.account_id}:instance-profile/${local.anyscale_cluster_node_role_name_prefix}*"
  )

  cloud_id_provided = var.anyscale_cloud_id != null ? true : false
}
# Allow Anyscale account access to assume this role.
data "aws_iam_policy_document" "iam_anyscale_crossacct_assumerole_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.anyscale_trusted_role_arns
    }

    dynamic "condition" {
      for_each = length(local.role_sts_externalid) != 0 ? [true] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = local.role_sts_externalid
      }
    }
  }
}

#Allow wildcard resources as these are locked down in other ways
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "iam_anyscale_steadystate_policy" {
  #checkov:skip=CKV_AWS_111:Write access required for these items

  statement {
    sid    = "IAM"
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "iam:GetInstanceProfile"
    ]
    resources = [
      local.anyscale_cluster_role_arn,
      local.anyscale_cluster_instance_profile_arn
    ]
  }
  statement {
    sid    = "RetrieveGenericAWSResources"
    effect = "Allow"
    actions = [
      # Populates metadata about what is available
      # in the account.
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeRegions",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "DescribeRunningResources"
    effect = "Allow"
    actions = [
      # Determines cluster/configuration status.
      "ec2:DescribeInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = local.cloud_id_provided ? [] : [1]
    content {
      sid    = "InstanceManagementCore"
      effect = "Allow"
      actions = [
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = local.cloud_id_provided ? [1] : []
    content {
      sid    = "RestrictInstanceStart"
      effect = "Allow"
      actions = [
        "ec2:StartInstances",
        "ec2:RunInstances"
      ]
      resources = [
        "arn:aws:ec2:*:${local.account_id}:instance/*"
      ]
      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/anyscale-cloud-id"
        values   = [var.anyscale_cloud_id]
      }
      condition {
        test     = "ForAnyValue:StringEquals"
        variable = "aws:TagKeys"
        values   = ["anyscale-cloud-id"]
      }
    }
  }

  dynamic "statement" {
    for_each = local.cloud_id_provided ? [1] : []
    content {
      sid    = "AllowRunInstancesForUntaggedResources"
      effect = "Allow"
      actions = [
        "ec2:RunInstances"
      ]
      resources = [
        "arn:aws:ec2:*::image/*",
        "arn:aws:ec2:*::snapshot/*",
        "arn:aws:ec2:*:*:subnet/*",
        "arn:aws:ec2:*:*:network-interface/*",
        "arn:aws:ec2:*:*:security-group/*",
        "arn:aws:ec2:*:*:key-pair/*",
        "arn:aws:ec2:*:*:volume/*"
      ]
    }
  }


  dynamic "statement" {
    for_each = local.cloud_id_provided ? [1] : []
    content {
      sid    = "RestrictEc2Termination"
      effect = "Allow"
      actions = [
        "ec2:TerminateInstances",
        "ec2:StopInstances"
      ]
      resources = [
        "arn:aws:ec2:*:${local.account_id}:instance/*"
      ]
      condition {
        test     = "StringEquals"
        variable = "aws:ResourceTag/anyscale-cloud-id"
        values   = [var.anyscale_cloud_id]
      }
    }
  }

  statement {
    sid    = "InstanceTagMangement"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = local.cloud_id_provided ? [1] : []
    content {
      sid    = "DenyTaggingOnOtherInstances"
      effect = "Deny"
      actions = [
        "ec2:CreateTags",
        "ec2:DeleteTags"
      ]
      resources = ["arn:aws:ec2:*:*:instance/*"]
      condition {
        test     = "StringNotEquals"
        variable = "aws:ResourceTag/anyscale-cloud-id"
        values   = [var.anyscale_cloud_id]
      }
      condition {
        test     = "StringNotEquals"
        variable = "ec2:CreateAction"
        values = [
          "RunInstances",
          "StartInstances"
        ]
      }
    }
  }

  statement {
    sid    = "InstanceManagementSpot"
    effect = "Allow"
    actions = [
      # Extended Permissions to Run Instances on Anyscale.
      "ec2:CancelSpotInstanceRequests",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:RequestSpotInstances",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "ResourceManagementExtended"
    effect = "Allow"
    actions = [
      # Volume management
      "ec2:AttachVolume",
      "ec2:CreateVolume",
      "ec2:DescribeVolumes",
      # IAMInstanceProfiles
      "ec2:AssociateIamInstanceProfile",
      "ec2:DisassociateIamInstanceProfile",
      "ec2:ReplaceIamInstanceProfileAssociation",
      # Placement groups
      "ec2:CreatePlacementGroup",
      # Address Management
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      # Additional DescribeResources
      "ec2:DescribeIamInstanceProfileAssociations",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribePlacementGroups",
      "ec2:DescribePrefixLists",
      "ec2:DescribeReservedInstancesOfferings",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeSpotPriceHistory"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "EFSManagement"
    effect    = "Allow"
    actions   = ["elasticfilesystem:DescribeMountTargets"]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "iam_anyscale_cluster_node_assumerole_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam_anyscale_s3_bucket_access" {
  dynamic "statement" {
    for_each = local.create_s3_bucket_policy ? [1] : []
    content {
      sid    = "S3BucketAccess"
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ]
      resources = [
        var.anyscale_s3_bucket_arn,
        "${var.anyscale_s3_bucket_arn}/*"
      ]
    }
  }
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "iam_anyscale_services_v2" {
  statement {
    sid    = "CloudformationCreateDescribe"
    effect = "Allow"
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResources",
      "cloudformation:DescribeStacks"
    ]
    resources = [
      "arn:aws:cloudformation:*:${local.account_id}:stack/*"
    ]
  }

  dynamic "statement" {
    for_each = local.cloud_id_provided ? [] : [1]
    content {
      sid    = "CloudformationWrite"
      effect = "Allow"
      actions = [
        "cloudformation:TagResource",
        "cloudformation:UntagResource",
        "cloudformation:UpdateStack",
      ]
      resources = [
        "arn:aws:cloudformation:*:${local.account_id}:stack/*"
      ]
    }
  }

  dynamic "statement" {
    for_each = local.cloud_id_provided ? [1] : []
    content {
      sid    = "CloudformationWrite"
      effect = "Allow"
      actions = [
        "cloudformation:TagResource",
        "cloudformation:UntagResource",
        "cloudformation:UpdateStack",
        "cloudformation:DeleteStack",
      ]
      resources = [
        "arn:aws:cloudformation:*:${local.account_id}:stack/*"
      ]
      condition {
        test     = "StringEquals"
        variable = "aws:ResourceTag/anyscale-cloud-id"
        values   = [var.anyscale_cloud_id]
      }
    }
  }

  statement {
    sid    = "CloudformationDelete"
    effect = "Allow"
    actions = [
      "cloudformation:DeleteStack",
    ]
    resources = [
      "arn:aws:cloudformation:*:${local.account_id}:stack/anyscale*"
    ]
  }

  statement {
    sid    = "ELBRead"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeListenerCertificates"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ACMAllResources"
    effect = "Allow"
    actions = [
      "acm:ListCertificates",
      "acm:RequestCertificate",
      "acm:DescribeCertificate",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = local.cloud_id_provided ? [] : [1]
    content {
      sid    = "ACMWrite"
      effect = "Allow"
      actions = [
        "acm:DeleteCertificate",
        "acm:RenewCertificate",
        "acm:AddTagsToCertificate",
        "acm:GetCertificate",
        "acm:ListTagsForCertificate"
      ]
      resources = ["arn:aws:acm:*:${local.account_id}:certificate/*"]
    }
  }

  dynamic "statement" {
    for_each = local.cloud_id_provided ? [1] : []
    content {
      sid    = "ACMWrite"
      effect = "Allow"
      actions = [
        "acm:DeleteCertificate",
        "acm:RenewCertificate",
        "acm:AddTagsToCertificate",
        "acm:GetCertificate",
        "acm:ListTagsForCertificate"
      ]
      resources = ["arn:aws:acm:*:${local.account_id}:certificate/*"]
      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/anyscale-cloud-id"
        values   = [var.anyscale_cloud_id]
      }
      condition {
        test     = "ForAnyValue:StringEquals"
        variable = "aws:TagKeys"
        values   = ["anyscale-cloud-id"]
      }
    }
  }

  statement {
    sid    = "ELBWrite"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:${local.account_id}:loadbalancer/app/Anyscale*",
      "arn:aws:elasticloadbalancing:*:${local.account_id}:listener/app/Anyscale*",
      "arn:aws:elasticloadbalancing:*:${local.account_id}:listener-rule/app/Anyscale*",
      "arn:aws:elasticloadbalancing:*:${local.account_id}:targetgroup/AnyscaleTarget*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:CalledViaFirst"
      values   = ["cloudformation.amazonaws.com"]
    }
  }
}
