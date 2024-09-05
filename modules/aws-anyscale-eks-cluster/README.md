[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-eks
This optional sub-module creates an Elastic Kubernetes Service for Anyscale applications and workloads.

EKS is a managed service that simplifies running Kubernetes on AWS without installing or maintaining your own Kubernetes control plane. It allows you to deploy, manage, and scale containerized applications using Kubernetes, leveraging the scalability and reliability of AWS. EKS integrates with other AWS services, providing a secure and highly available environment for cloud workloads.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.64.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.anyscale_dataplane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_iam_openid_connect_provider.anyscale_dataplane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [tls_certificate.anyscale_dataplane](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | (Optional) A list of additional security group IDs to use for the EKS cluster.<br><br>ex:<pre>additional_security_group_ids = ["sg-1234567890abcdef1", "sg-1234567890abcdef2"]</pre> | `list(string)` | `[]` | no |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID.<br><br>ex:<pre>anyscale_cloud_id = "cld_1234567890abcdef0"</pre> | `string` | `null` | no |
| <a name="input_anyscale_eks_name"></a> [anyscale\_eks\_name](#input\_anyscale\_eks\_name) | (Optional) Anyscale EKS Name.<br><br>If left `null`, will default to `anyscale-eks` in a local variable.<br><br>ex:<pre>anyscale_eks_name = "anyscale-eks"</pre> | `string` | `null` | no |
| <a name="input_anyscale_security_group_id"></a> [anyscale\_security\_group\_id](#input\_anyscale\_security\_group\_id) | (Optional) Anyscale Security Group ID.<br><br>Required if `module_enabled` is true.<br><br>ex:<pre>anyscale_security_group_id = "sg-1234567890abcdef0"</pre> | `string` | `null` | no |
| <a name="input_anyscale_subnet_count"></a> [anyscale\_subnet\_count](#input\_anyscale\_subnet\_count) | (Optional) The mount targets subnet count.<br><br>This is included as the number of subnets is not always known at the creation time.<br><br>ex:<pre>anyscale_subnet_count = 2</pre> | `number` | `0` | no |
| <a name="input_anyscale_subnet_ids"></a> [anyscale\_subnet\_ids](#input\_anyscale\_subnet\_ids) | (Optional) A list of subnet IDs to use for the EKS cluster.<br><br>Required if `module_enabled` is true.<br><br>ex:<pre>anyscale_subnet_ids = ["subnet-1234567890abcdef0", "subnet-1234567890abcdef1"]</pre> | `list(string)` | `[]` | no |
| <a name="input_eks_addons"></a> [eks\_addons](#input\_eks\_addons) | (Optional) Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources.<br><br>ex:<pre>eks_addons = [<br>  {<br>    addon_name           = "vpc-cni"<br>    addon_version        = "1.8.0"<br>    configuration_values = null<br>    resolve_conflicts_on_create = null<br>    resolve_conflicts_on_update = null<br>    service_account_role_arn    = null<br>    create_timeout              = null<br>    update_timeout              = null<br>    delete_timeout              = null<br>  }<br>]</pre> | <pre>list(object({<br>    addon_name                  = string<br>    addon_version               = optional(string, null)<br>    configuration_values        = optional(string, null)<br>    resolve_conflicts_on_create = optional(string, null)<br>    resolve_conflicts_on_update = optional(string, null)<br>    service_account_role_arn    = optional(string, null)<br>    create_timeout              = optional(string, null)<br>    update_timeout              = optional(string, null)<br>    delete_timeout              = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_eks_addons_depends_on"></a> [eks\_addons\_depends\_on](#input\_eks\_addons\_depends\_on) | (Optional) If provided, all addons will depend on this object, and therefore not be installed until this object is finalized.<br><br>This is useful if you want to ensure that addons are not applied before some other condition is met, e.g. node groups are created.<br><br>ex:<pre>addons_depends_on = [aws_eks_node_group.management]</pre> | `any` | `null` | no |
| <a name="input_eks_cluster_encryption_config_kms_key_arn"></a> [eks\_cluster\_encryption\_config\_kms\_key\_arn](#input\_eks\_cluster\_encryption\_config\_kms\_key\_arn) | (Optional) KMS Key ID to use for cluster encryption config<br><br>ex:<pre>eks_cluster_encryption_config_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"</pre> | `string` | `null` | no |
| <a name="input_eks_cluster_encryption_config_resources"></a> [eks\_cluster\_encryption\_config\_resources](#input\_eks\_cluster\_encryption\_config\_resources) | (Optional) Cluster Encryption Config Resources to encrypt.<br><br>ex:<pre>eks_cluster_encryption_config_resources = ["secrets"]</pre> | `list(any)` | <pre>[<br>  "secrets"<br>]</pre> | no |
| <a name="input_eks_cluster_securitygroup_id"></a> [eks\_cluster\_securitygroup\_id](#input\_eks\_cluster\_securitygroup\_id) | (Optional) The ID of the security group to use for the EKS cluster.<br><br>Required if `create_eks_cluster_securitygroup` is false.<br><br>ex:<pre>eks_cluster_securitygroup_id = "sg-1234567890abcdef0"</pre> | `string` | `null` | no |
| <a name="input_eks_endpoint_private_access"></a> [eks\_endpoint\_private\_access](#input\_eks\_endpoint\_private\_access) | (Optional) Determines whether or not the Amazon EKS private API server endpoint is enabled.<br><br>ex:<pre>eks_endpoint_private_access = true</pre> | `bool` | `false` | no |
| <a name="input_eks_endpoint_public_access"></a> [eks\_endpoint\_public\_access](#input\_eks\_endpoint\_public\_access) | (Optional) Indicates whether or not the Amazon EKS public API server endpoint is enabled<br><br>ex:<pre>eks_endpoint_public_access = true</pre> | `bool` | `true` | no |
| <a name="input_eks_endpoint_public_access_cidrs"></a> [eks\_endpoint\_public\_access\_cidrs](#input\_eks\_endpoint\_public\_access\_cidrs) | (Optional) List of CIDR blocks that are allowed to access the Amazon EKS public API server endpoint.<br><br>ex:<pre>eks_endpoint_public_access_cidrs = ["12.1.30.32/32", "13.10.0.0/16"]</pre> | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_eks_role_arn"></a> [eks\_role\_arn](#input\_eks\_role\_arn) | (Optional) The ARN of the IAM role to use for the EKS cluster.<br><br>Required if `module_enabled` is true.<br><br>ex:<pre>anyscale_eks_role_arn = "arn:aws:iam::123456789012:role/eks-service-role"</pre> | `string` | `null` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | (Optional) A list of the desired control plane logs to enable.<br><br>For more information, see Amazon EKS Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)<br><br>ex:<pre>enabled_cluster_log_types = ["api", "audit", "authenticator"]</pre> | `list(string)` | `[]` | no |
| <a name="input_include_version_in_name"></a> [include\_version\_in\_name](#input\_include\_version\_in\_name) | (Optional) Determines if the Kubernetes version should be included in the EKS cluster name.<br><br>If `anyscale_eks_name` is provided, it will override this variable.<br><br>ex:<pre>include_version_in_name = true</pre> | `bool` | `true` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | (Optional) The Kubernetes version to use for the EKS cluster.<br><br>Must be on EKS v1.28 or greater.<br>Downgrades are not supported.<br><br>ex:<pre>kubernetes_version = "1.28"</pre> | `string` | `"1.30"` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines if this module should create resources.<br><br>If set to true, `eks_role_arn`, and `anyscale_subnet_ids` must be provided.<br>ex:<pre>module_enabled = true</pre> | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources.<br><br>If cloud\_id is provided, it will be added to the tags.<br><br>ex:<pre>tags = {<br>  test        = true<br>  environment = "test"<br>}</pre> | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_managed_security_group_id"></a> [cluster\_managed\_security\_group\_id](#output\_cluster\_managed\_security\_group\_id) | Security Group ID that was created by EKS for the cluster.<br>EKS creates a Security Group and applies it to the ENI that are attached to EKS Control Plane master nodes and to any managed workloads. |
| <a name="output_eks_cluster_arn"></a> [eks\_cluster\_arn](#output\_eks\_cluster\_arn) | ARN of the Anyscale EKS cluster |
| <a name="output_eks_cluster_ca_data"></a> [eks\_cluster\_ca\_data](#output\_eks\_cluster\_ca\_data) | Certificate Authority Data of the Anyscale EKS cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | Endpoint of the Anyscale EKS cluster |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | ID of the Anyscale EKS cluster |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | Name of the Anyscale EKS cluster |
| <a name="output_eks_cluster_oidc_provider_arn"></a> [eks\_cluster\_oidc\_provider\_arn](#output\_eks\_cluster\_oidc\_provider\_arn) | OIDC provider of the Anyscale EKS cluster |
| <a name="output_eks_cluster_oidc_provider_url"></a> [eks\_cluster\_oidc\_provider\_url](#output\_eks\_cluster\_oidc\_provider\_url) | OIDC provider URL of the Anyscale EKS cluster |
| <a name="output_eks_kubeconfig"></a> [eks\_kubeconfig](#output\_eks\_kubeconfig) | Kubeconfig of the Anyscale EKS cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
