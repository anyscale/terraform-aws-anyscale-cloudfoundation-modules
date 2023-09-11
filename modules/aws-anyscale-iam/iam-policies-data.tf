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

  anyscale_trusted_role_arns = coalescelist(
    var.anyscale_trusted_role_arns, var.anyscale_default_trusted_role_arns
  )

  cloud_id_provided         = var.anyscale_cloud_id != null ? true : false
  cloud_and_org_id_provided = var.anyscale_cloud_id != null && var.anyscale_org_id != null ? true : false
  org_id_provided           = var.anyscale_org_id != null ? true : false

  log_group_cloud_and_org_id_arn = local.cloud_and_org_id_provided ? "arn:aws:logs:*:${local.account_id}:log-group:/anyscale*" : null
  log_group_org_id_arn           = local.org_id_provided ? "arn:aws:logs:*:${local.account_id}:log-group:/anyscale*" : null
  log_group_cloud_id_arn         = local.cloud_id_provided ? "arn:aws:logs:*:${local.account_id}:log-group:/anyscale*" : null
  log_group_arn = coalesce(
    local.log_group_cloud_and_org_id_arn,
    local.log_group_org_id_arn,
    local.log_group_cloud_id_arn,
    "arn:aws:logs:*:${local.account_id}:log-group:/anyscale*"
  )
}
# Allow Anyscale account access to assume this role.
data "aws_iam_policy_document" "iam_anyscale_crossacct_assumerole_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.anyscale_trusted_role_arns
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
  #checkov:skip=CKV_AWS_356:Wildcards allowed for these items

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
      "ec2:DescribeAccountAttributes",
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

  statement {
    sid    = "CreateSpotServiceRole"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["spot.amazonaws.com"]
    }
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
      "ec2:DescribeSpotPriceHistory",
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

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "iam_anyscale_s3_bucket_access" {
  dynamic "statement" {
    for_each = local.create_s3_bucket_access_policy ? [1] : []
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
  #checkov:skip=CKV_AWS_356:Policy requires wildcards in resource permissions'
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

  statement {
    sid    = "EC2Describe"
    effect = "Allow"
    actions = [
      # VPC Describe Resources
      "ec2:DescribeVpcs",
      "ec2:DescribeInternetGateways",
    ]
    resources = ["*"]
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
    sid    = "CreateELBServiceLinkedRole"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"
    ]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    sid    = "ELBRead"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
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
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:SetRulePriorities",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets"
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

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "cluster_node_cloudwatch_access" {
  #checkov:skip=CKV_AWS_356:Policy requires wildcards in resource permissions
  statement {
    sid    = "CloudwatchMetricsWrite"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudwatchLogsRead"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudwatchLogsEventsWrite"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
    ]
    resources = ["${local.log_group_arn}:*"]

  }

  statement {
    sid    = "CloudwatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      # "logs:PutRetentionPolicy",
    ]
    resources = [
      local.log_group_arn,
    ]
  }

}

locals {
  secrets_policy_body = var.anyscale_cluster_node_byod_secret_kms_arn != null ? templatefile(
    "${path.module}/cluster_node-secretsmanager-getsecret-kms.tmpl",
    {
      anyscale_cluster_node_byod_secret_arns    = jsonencode(var.anyscale_cluster_node_byod_secret_arns)
      anyscale_cluster_node_byod_secret_kms_arn = jsonencode(var.anyscale_cluster_node_byod_secret_kms_arn)
    }
    ) : templatefile(
    "${path.module}/cluster_node-secretsmanager-getsecret.tmpl",
    {
      anyscale_cluster_node_byod_secret_arns = jsonencode(var.anyscale_cluster_node_byod_secret_arns)
    }
  )
  secrets_policy_doc = try(length(var.anyscale_cluster_node_byod_custom_secrets_policy), 0) > 0 ? var.anyscale_cluster_node_byod_custom_secrets_policy : local.secrets_policy_body
}
data "aws_iam_policy_document" "cluster_node_secretmanager_read_access" {
  count = var.module_enabled && local.create_secrets_policy ? 1 : 0

  source_policy_documents = [local.secrets_policy_doc]
}
