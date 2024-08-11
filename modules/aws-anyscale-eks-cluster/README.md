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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.62.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.anyscale_dataplane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | (Optional) A list of additional security group IDs to use for the EKS cluster.<br><br>ex:<pre>additional_security_group_ids = ["sg-1234567890abcdef1", "sg-1234567890abcdef2"]</pre> | `list(string)` | `[]` | no |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID.<br><br>ex:<pre>anyscale_cloud_id = "cld_1234567890abcdef0"</pre> | `string` | `null` | no |
| <a name="input_anyscale_eks_name"></a> [anyscale\_eks\_name](#input\_anyscale\_eks\_name) | (Optional) Anyscale EKS Name.<br><br>If not provided, the name will be generated based on the cloud\_id.<br><br>ex:<pre>anyscale_eks_name = "anyscale-eks"</pre> | `string` | `null` | no |
| <a name="input_anyscale_security_group_id"></a> [anyscale\_security\_group\_id](#input\_anyscale\_security\_group\_id) | (Optional) The ID of the security group to use for the EKS cluster.<br><br>Required if `module_enabled` is true.<br><br>ex:<pre>anyscale_security_group_id = "sg-1234567890abcdef0"</pre> | `string` | `null` | no |
| <a name="input_anyscale_subnet_count"></a> [anyscale\_subnet\_count](#input\_anyscale\_subnet\_count) | (Optional) The mount targets subnet count.<br><br>This is included as the number of subnets is not always known at the creation time.<br><br>ex:<pre>anyscale_subnet_count = 2</pre> | `number` | `0` | no |
| <a name="input_anyscale_subnet_ids"></a> [anyscale\_subnet\_ids](#input\_anyscale\_subnet\_ids) | (Optional) A list of subnet IDs to use for the EKS cluster.<br><br>Required if `module_enabled` is true.<br><br>ex:<pre>anyscale_subnet_ids = ["subnet-1234567890abcdef0", "subnet-1234567890abcdef1"]</pre> | `list(string)` | `[]` | no |
| <a name="input_eks_cluster_encryption_config_kms_key_arn"></a> [eks\_cluster\_encryption\_config\_kms\_key\_arn](#input\_eks\_cluster\_encryption\_config\_kms\_key\_arn) | (Optional) KMS Key ID to use for cluster encryption config<br><br>ex:<pre>eks_cluster_encryption_config_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"</pre> | `string` | `null` | no |
| <a name="input_eks_cluster_encryption_config_resources"></a> [eks\_cluster\_encryption\_config\_resources](#input\_eks\_cluster\_encryption\_config\_resources) | (Optional) Cluster Encryption Config Resources to encrypt.<br><br>ex:<pre>eks_cluster_encryption_config_resources = ["secrets"]</pre> | `list(any)` | <pre>[<br>  "secrets"<br>]</pre> | no |
| <a name="input_eks_endpoint_private_access"></a> [eks\_endpoint\_private\_access](#input\_eks\_endpoint\_private\_access) | (Optional) Determines whether or not the Amazon EKS private API server endpoint is enabled.<br><br>ex:<pre>eks_endpoint_private_access = true</pre> | `bool` | `false` | no |
| <a name="input_eks_endpoint_public_access"></a> [eks\_endpoint\_public\_access](#input\_eks\_endpoint\_public\_access) | (Optional) Indicates whether or not the Amazon EKS public API server endpoint is enabled<br><br>ex:<pre>eks_endpoint_public_access = true</pre> | `bool` | `true` | no |
| <a name="input_eks_endpoint_public_access_cidrs"></a> [eks\_endpoint\_public\_access\_cidrs](#input\_eks\_endpoint\_public\_access\_cidrs) | (Optional) List of CIDR blocks that are allowed to access the Amazon EKS public API server endpoint.<br><br>ex:<pre>eks_endpoint_public_access_cidrs = ["12.1.30.32/32", "13.10.0.0/16"]</pre> | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_eks_role_arn"></a> [eks\_role\_arn](#input\_eks\_role\_arn) | (Optional) The ARN of the IAM role to use for the EKS cluster.<br><br>Required if `module_enabled` is true.<br><br>ex:<pre>anyscale_eks_role_arn = "arn:aws:iam::123456789012:role/eks-service-role"</pre> | `string` | `null` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | (Optional) A list of the desired control plane logs to enable.<br><br>For more information, see Amazon EKS Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)<br><br>ex:<pre>enabled_cluster_log_types = ["api", "audit", "authenticator"]</pre> | `list(string)` | `[]` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | (Optional) The Kubernetes version to use for the EKS cluster.<br><br>Must be on EKS v1.28 or greater.<br>Downgrades are not supported.<br><br>ex:<pre>kubernetes_version = "1.28"</pre> | `string` | `"1.28"` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines if this module should create resources.<br><br>If set to true, `eks_role_arn`, `anyscale_subnet_ids`, and `anyscale_security_group_id` must be provided.<br>ex:<pre>module_enabled = true</pre> | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources.<br><br>If cloud\_id is provided, it will be added to the tags.<br><br>ex:<pre>tags = {<br>  test        = true<br>  environment = "test"<br>}</pre> | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_arn"></a> [eks\_cluster\_arn](#output\_eks\_cluster\_arn) | ARN of the Anyscale EKS cluster |
| <a name="output_eks_cluster_certificate_authority_data"></a> [eks\_cluster\_certificate\_authority\_data](#output\_eks\_cluster\_certificate\_authority\_data) | Certificate Authority Data of the Anyscale EKS cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | Endpoint of the Anyscale EKS cluster |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | ID of the Anyscale EKS cluster |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | Name of the Anyscale EKS cluster |
| <a name="output_eks_kubeconfig"></a> [eks\_kubeconfig](#output\_eks\_kubeconfig) | Kubeconfig of the Anyscale EKS cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions