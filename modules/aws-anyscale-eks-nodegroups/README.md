[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-eks-nodegroups
This sub-module creates EKS Node Groups for Anyscale.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.62.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.anyscale_node_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | (Required) The name of the EKS cluster.<br><br>ex:<pre>cluster_name = "anyscale-cluster"</pre> | `string` | n/a | yes |
| <a name="input_eks_node_role_arn"></a> [eks\_node\_role\_arn](#input\_eks\_node\_role\_arn) | (Required) The ARN of the IAM role to use for the EKS nodes.<br><br>ex:<pre>eks_node_role_arn = "arn:aws:iam::123456789012:role/eks-node-role"</pre> | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Required) A list of subnet IDs to use for the EKS nodes.<br><br>ex:<pre>subnet_ids = ["subnet-1234567890abcdef0", "subnet-1234567890abcdef1"]</pre> | `list(string)` | n/a | yes |
| <a name="input_create_anyscale_node_groups"></a> [create\_anyscale\_node\_groups](#input\_create\_anyscale\_node\_groups) | (Optional) Determines if this module should create Anyscale EKS Node Groups.<br><br>ex:<pre>create_anyscale_node_groups = true</pre> | `bool` | `true` | no |
| <a name="input_create_eks_management_node_group"></a> [create\_eks\_management\_node\_group](#input\_create\_eks\_management\_node\_group) | (Optional) Determines if this module should create a EKS Management Node Group.<br><br>The EKS Management Node Group will be use for EKS Management pods.<br><br>ex:<pre>create_eks_management_node_group = true</pre> | `bool` | `true` | no |
| <a name="input_eks_anyscale_node_groups"></a> [eks\_anyscale\_node\_groups](#input\_eks\_anyscale\_node\_groups) | (Optional) A list of Anyscale EKS Node Group configurations.<br><br>ex:<pre>eks_anyscale_node_groups = [<br>  {<br>    name           = "anyscale-spot-cpu"<br>    instance_types = ["m5.large"]<br>    capacity_type  = "SPOT"<br>    labels         = {<br>      "node-type" = "anyscale"<br>    }<br>    tags           = {<br>      "test"        = true<br>      "environment" = "test"<br>    }<br>    ami_type       = "AL2_x86_64"<br>    disk_size      = 500 # Recommended to be at least 500GB. If not provided, will default to 500GB.<br>    scaling_config = {<br>      desired_size = 0<br>      max_size     = 4<br>      min_size     = 0<br>    }<br>    update_config = {<br>      max_unavailable_percentage = 33<br>    }<br>    taints = [<br>      {<br>        key    = "node-type"<br>        value  = "anyscale"<br>        effect = "NO_SCHEDULE" # or "NO_EXECUTE" or "PREFER_NO_SCHEDULE"<br>      }<br>    ]<br>  },<br>  ...<br>]</pre> | <pre>list(<br>    object({<br>      name           = string<br>      instance_types = list(string)<br>      capacity_type  = string<br>      labels         = optional(map(string))<br>      tags           = optional(map(string))<br>      ami_type       = optional(string)<br>      disk_size      = optional(number)<br>      scaling_config = object({<br>        desired_size = number<br>        max_size     = number<br>        min_size     = number<br>      })<br>      update_config = optional(object({<br>        max_unavailable_percentage = optional(number)<br>        max_unavailable            = optional(number)<br>      }))<br>      taints = optional(list(<br>        object({<br>          key    = string<br>          value  = string<br>          effect = string<br>        })<br>      ))<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "ami_type": "AL2_x86_64_GPU",<br>    "capacity_type": "ON_DEMAND",<br>    "instance_types": [<br>      "m6a.2xlarge",<br>      "m5a.2xlarge",<br>      "m6i.2xlarge",<br>      "m5.2xlarge"<br>    ],<br>    "name": "anyscale-ondemand-cpu-8CPU-32GB",<br>    "scaling_config": {<br>      "desired_size": 0,<br>      "max_size": 50,<br>      "min_size": 0<br>    },<br>    "tags": {},<br>    "taints": []<br>  },<br>  {<br>    "ami_type": "AL2_x86_64_GPU",<br>    "capacity_type": "ON_DEMAND",<br>    "instance_types": [<br>      "m6a.4xlarge",<br>      "m5a.4xlarge",<br>      "m6i.4xlarge",<br>      "m5.4xlarge"<br>    ],<br>    "name": "anyscale-ondemand-cpu-16CPU-64GB",<br>    "scaling_config": {<br>      "desired_size": 0,<br>      "max_size": 50,<br>      "min_size": 0<br>    },<br>    "tags": {},<br>    "taints": []<br>  }<br>]</pre> | no |
| <a name="input_eks_management_node_group_config"></a> [eks\_management\_node\_group\_config](#input\_eks\_management\_node\_group\_config) | (Optional) Configuration for the EKS Management Node Group.<br><br>ex:<pre>eks_management_node_group_config = {<br>  instance_types = ["t3.medium"]<br>  capacity_type  = "ON_DEMAND"<br>  desired_size   = 2<br>  max_size       = 4<br>  min_size       = 1<br>  labels         = {<br>    "node-type" = "management"<br>  }<br>  tags           = {<br>    "test"        = true<br>    "environment" = "test"<br>  }<br>  ami_type      = "AL2_x86_64"<br>  taints = [<br>    {<br>      key    = "node-type"<br>      value  = "management"<br>      effect = "NO_SCHEDULE"<br>    }<br>  ]<br>  update_config = {<br>    max_unavailable_percentage = 33<br>  }<br>}</pre> | <pre>object({<br>    name           = string<br>    instance_types = list(string)<br>    capacity_type  = string<br>    labels         = optional(map(string))<br>    tags           = optional(map(string))<br>    ami_type       = optional(string)<br>    scaling_config = object({<br>      desired_size = number<br>      max_size     = number<br>      min_size     = number<br>    })<br>    update_config = optional(object({<br>      max_unavailable_percentage = optional(number)<br>      max_unavailable            = optional(number)<br>    }))<br>    taints = optional(list(<br>      object({<br>        key    = string<br>        value  = string<br>        effect = string<br>      })<br>    ))<br>  })</pre> | <pre>{<br>  "ami_type": "AL2_x86_64",<br>  "capacity_type": "ON_DEMAND",<br>  "instance_types": [<br>    "t3.medium"<br>  ],<br>  "labels": {<br>    "node-type": "management"<br>  },<br>  "name": "eks-mng",<br>  "scaling_config": {<br>    "desired_size": 2,<br>    "max_size": 4,<br>    "min_size": 1<br>  },<br>  "tags": {},<br>  "taints": [],<br>  "update_config": {<br>    "max_unavailable_percentage": 33<br>  }<br>}</pre> | no |
| <a name="input_force_update_version"></a> [force\_update\_version](#input\_force\_update\_version) | (Optional) Determines if, when updating the Kubernetes version, pods are foreably removed.<br><br>If set to true, if PodDisruptionBudget or taint/toleration issues would otherwise prevent them from being removed (and cause the update to fail) it will be removed.<br><br>ex:<pre>force_update_version = true</pre> | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | (Optional) The Kubernetes version to use for the EKS cluster.<br><br>Must be on EKS v1.28 or greater.<br>Downgrades are not supported.<br><br>ex:<pre>kubernetes_version = "1.28"</pre> | `string` | `"1.30"` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines if this module should create resources.<br><br>If set to true, `eks_cluster_name`, `eks_node_role_arn`, and `anyscale_subnet_ids` must be provided.<br>ex:<pre>module_enabled = true</pre> | `bool` | `false` | no |
| <a name="input_node_group_timeouts"></a> [node\_group\_timeouts](#input\_node\_group\_timeouts) | (Optional) Create, update, and delete timeout configurations for the node group<br><br>ex:<pre>node_group_timeouts = {<br>  create = "30m"<br>  update = "30m"<br>  delete = "30m"<br>}</pre> | <pre>list(object({<br>    create = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "create": "20m",<br>    "delete": "20m",<br>    "update": "20m"<br>  }<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources.<br><br>If cloud\_id is provided, it will be added to the tags.<br><br>ex:<pre>tags = {<br>  test        = true<br>  environment = "test"<br>}</pre> | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
