# Decisions & Preferences
This document outlines the potential decisions which can be made prior to deployment to speed up the process. 

## 1. Networking Architecture
- Direct Networking (simple): Public subnets, public IPs, internet-facing
- Customer Defined Networking (enterprise): Private subnets, NAT gateways, more secure
- Decision: Most enterprises choose Customer Defined with --private-network flag

## 2. VPC Strategy
- New VPC: Create dedicated (recommended /16 CIDR like 10.0.0.0/16)
- Existing VPC: Integrate with current network infrastructure
- Decision: Do you have existing VPC requirements or create new?

## 3. Subnet Design
- Number: Minimum 2, recommended 3+ for multi-AZ
- Size: /22 CIDR (1,024 IPs each) recommended
- Type: Public only vs Private with NAT
- Decision: How many subnets and in which availability zones?

## 4. Access Control
- Ingress CIDR ranges: Which IPs can access clusters (office, VPN, CI/CD)
- SSH access: Enable port 22 or use SSM only?
- Machine pools: Up to 2 CIDR ranges maximum (AWS limit)
- Decision: Define your security_group_ingress_allow_access_from_cidr_range

## 5. IAM Configuration
- External ID: Use format org_id-custom_string for enhanced security
- CloudWatch logs: Enable cluster logging to CloudWatch?
- Custom policies: Additional permissions for Secrets Manager, RDS, etc.?
- Decision: What additional AWS services will clusters need?

## 6. Storage Options
S3 Bucket:
- New dedicated vs existing bucket
- Encryption: AES256 (default) or KMS
- Lifecycle policies for cost optimization
- Decision: KMS encryption required by compliance?

EFS (Optional):
- Shared cluster storage
- Decision: Set create_efs_resources true/false

MemoryDB (Optional):
- Head node fault tolerance for Services
- Decision: Set create_memorydb_resources true/false (recommend true for production)

## 7. Region & Availability
- Region: Which AWS region? (no China/GovCloud)
- Multi-AZ: Distribute across 2-3 availability zones
- VPC Endpoints: Create S3 endpoint for cost/performance?
- Decision: Primary region and DR strategy?

## 8. Resource Naming
- Common naming: Use use_common_name=true for consistency
- Prefix: Define common_prefix (e.g., "company-anyscale-")
- Tags: Cost center, environment, owner tags
- Decision: Naming convention and tagging strategy

## 9. Environment Strategy
- Separation: Separate clouds per environment or shared?
- Deployment env: Set anyscale_deploy_env (dev/staging/prod)
- Decision: How many Anyscale clouds needed?

## 10. Compliance & Security
- AWS Account: Dedicated or shared account?
- KMS keys: Customer-managed keys required?
- Audit logging: CloudWatch logs enabled?
- Decision: What are your compliance requirements?