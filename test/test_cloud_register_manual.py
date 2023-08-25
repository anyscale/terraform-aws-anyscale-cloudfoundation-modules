# This script will be used by SA team to:
# Test the following functionalities work well together:
# 1. terraform
# 2. cloud register
# 3. cloud functional verification

# Prerequisites:
# 1. (for AWS) Use the AWS credentials that you want to create resources in.
#    (for GCP) It will need your GCP credentials as you run.
# 2. Use the anyscale credentials that you want to register the cloud to.
# 3. Have terraform installed and python package python_terraform installed.
# 4. Run this script in product repo.

from datetime import datetime
import re
import subprocess
import argparse
import boto3

from python_terraform import IsFlagged, IsNotFlagged, Terraform

from anyscale.controllers.cloud_controller import CloudController


# Feel free to edit the following variables for AWS
def _get_terraform_anyscale_v2_e2e_public_vars_aws():
    """Get the variables for the aws terraform apply.
    The variables are required by the terraform as input variables.
    """
    return {
        "aws_region": "us-east-2",
        "customer_ingress_cidr_ranges": "0.0.0.0/0",
        "anyscale_access_role_trusted_role_arns": [
            "arn:aws:iam::623395924981:root",  # staging
            "arn:aws:iam::521861002309:root",  # predeploy
            "arn:aws:iam::525325868955:root",  # production
        ],
    }


# Feel free to edit the following variables for GCP
def _get_terraform_anyscale_v2_e2e_public_vars_gcp():
    """Get the variables for the gcp anyscale-v2-commonname terraform apply.
    The variables are required by the terraform as input variables.
    """
    return {
        "anyscale_google_region": "us-central1",
        "anyscale_google_zone": "us-central1-a",
        "anyscale_org_id": "org_7c1Kalm9WcX2bNIjW53GUT",  # Anyscale org id.
        "billing_account_id": "01D34E-9FCF25-2A378C",  # Anyscale billing account id.
        "customer_ingress_cidr_ranges": "52.1.1.23/32,10.1.0.0/16",  # Suggested by the terraform.  # noqa: E501
        "root_folder_number": "953296303039",  # This is the folder id of the folder "cloud-setup-terraform-test" in gcp.  # noqa: E501
        # 623395924981 for staging, 521861002309 for predeploy, 525325868955 for production  # noqa: E501
        "workload_identity_account_id": "525325868955",
    }


def _parse_registration_command(input_string):
    """Parse the registration command from the terraform output."""
    pattern = r"EOT\n(.*?)EOT"
    match = re.search(pattern, input_string, re.DOTALL)
    if not match:
        return None

    registration_command = match.group(1)
    print(registration_command)
    return _parse_options(registration_command)


def _parse_options(input_string):
    """Parse the options from the registration command."""
    matches = re.findall(r"--(\S+?)\s(\S+)", input_string)
    return {key: value.strip() for key, value in matches}


def start_aws_test(branch_name: str, local_path: str):
    # If you have some error like "destination path 'terraform-aws-anyscale-cloudfoundation-modules' already exists and is not an empty directory",  # noqa: E501
    # remove the terraform-aws-anyscale-cloudfoundation-modules folder and run this script again.  # noqa: E501
    # "sudo rm -r terraform-aws-anyscale-cloudfoundation-modules"
    print("Starting aws test...")

    if local_path:
        print("Using local path...")
        working_dir = local_path
    else:
        print("Cloning the repo...")
        repo_url = "https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/"
        subprocess.check_call(["git", "clone", repo_url])
        # Checkout to a specific branch
        subprocess.check_call(
            ["git", "checkout", branch_name],
            cwd="terraform-aws-anyscale-cloudfoundation-modules",
        )
        working_dir = "terraform-aws-anyscale-cloudfoundation-modules/test/anyscale-v2-e2e-public-test"  # noqa: E501

    tf = Terraform(
        working_dir=working_dir,
        variables=_get_terraform_anyscale_v2_e2e_public_vars_aws(),
    )
    tf.init()
    print(
        "Applying anyscale_v2_e2e_public aws terraform... (It will take about 2~5 minutes)"  # noqa: E501
    )
    # To debug, we can add capture_output=False to see the stdout, in which case the stdout will be None.  # noqa: E501
    return_code, stdout, stderr = tf.apply(skip_plan=True)
    if return_code != 0:
        raise RuntimeError(
            f"Error applying anyscale_v2_e2e_public aws terraform: {stderr}"
        )
    print(f"Applied anyscale_v2_e2e_public aws result: {stdout}")

    ## Register the cloud.
    cloud_name = (
        f"test_terraform_anyscale_v2_e2e_public_aws_{datetime.now().isoformat()}"
    )
    stdout_dict = _parse_registration_command(stdout)
    print(f"Parsed stdout_dict: {stdout_dict}")
    s3_bucket_id = stdout_dict.get("s3-bucket-id")
    print("Registering cloud...")
    cloud_controller = CloudController()
    cloud_controller.register_aws_cloud(
        region=stdout_dict.get("region"),
        name=cloud_name,
        vpc_id=stdout_dict.get("vpc-id"),
        subnet_ids=stdout_dict.get("subnet-ids").split(","),
        efs_id=stdout_dict.get("efs-id"),
        anyscale_iam_role_id=stdout_dict.get("anyscale-iam-role-id"),
        instance_iam_role_id=stdout_dict.get("instance-iam-role-id"),
        security_group_ids=stdout_dict.get("security-group-ids").split(","),
        s3_bucket_id=s3_bucket_id,
        # change to functional_verify="workspace,service" once service is ready.
        # For functional verify, the console will ask for your confirm to proceed.
        functional_verify="workspace",
        private_network=False,
        cluster_management_stack_version="v2",
        yes=True,
    )
    print("Cloud registered successfully")

    ## Delete the cloud.
    print("Deleting cloud...")
    cloud_controller.delete_cloud(
        cloud_name=cloud_name,
        cloud_id="",
        skip_confirmation=True,
    )
    print("Cloud deleted successfully")

    ## Emptying the s3 bucket.
    print(f"Emptying s3 bucket {s3_bucket_id}...")
    s3_client = boto3.client("s3")
    object_response_paginator = s3_client.get_paginator("list_object_versions")
    delete_marker_list = []
    version_list = []
    for object_response_itr in object_response_paginator.paginate(Bucket=s3_bucket_id):
        if "DeleteMarkers" in object_response_itr:
            for delete_marker in object_response_itr["DeleteMarkers"]:
                delete_marker_list.append(
                    {
                        "Key": delete_marker["Key"],
                        "VersionId": delete_marker["VersionId"],
                    }
                )

        if "Versions" in object_response_itr:
            for version in object_response_itr["Versions"]:
                version_list.append(
                    {"Key": version["Key"], "VersionId": version["VersionId"]}
                )

    for i in range(0, len(delete_marker_list), 1000):
        response = s3_client.delete_objects(
            Bucket=s3_bucket_id,
            Delete={"Objects": delete_marker_list[i : i + 1000], "Quiet": True},
        )
        print(response)

    for i in range(0, len(version_list), 1000):
        response = s3_client.delete_objects(
            Bucket=s3_bucket_id,
            Delete={"Objects": version_list[i : i + 1000], "Quiet": True},
        )
        print(response)

    print(f"S3 bucket {s3_bucket_id} emptied successfully")
    ## Destroy the terraform.
    print("Destroying anyscale_v2_e2e_public aws terraform...")
    return_code, stdout, stderr = tf.destroy(force=IsNotFlagged, auto_approve=IsFlagged)
    if return_code != 0:
        raise RuntimeError(
            f"Error destroying anyscale_v2_e2e_public aws terraform: {stderr}"
        )
    print(f"Destroyed anyscale_v2_e2e_public aws terraform successfully {stdout}")


def start_gcp_test(branch_name: str):
    repo_url = (
        "https://github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules/"
    )
    subprocess.check_call(["git", "clone", repo_url])
    # Checkout to a specific branch
    subprocess.check_call(
        ["git", "checkout", branch_name],
        cwd="terraform-aws-anyscale-cloudfoundation-modules",
    )

    working_dir = "terraform-google-anyscale-cloudfoundation-modules/test/anyscale-v2-e2e-public-test"  # noqa: E501
    tf = Terraform(
        working_dir=working_dir,
        variables=_get_terraform_anyscale_v2_e2e_public_vars_gcp(),
    )
    tf.init()
    print(
        "Applying anyscale_v2_e2e_public gcp terraform... (It will take about 10 minutes)"  # noqa: E501
    )
    # To debug, we can add capture_output=False to see the stdout, in which case the stdout will be None.  # noqa: E501
    return_code, stdout, stderr = tf.apply(skip_plan=True)
    if return_code != 0:
        raise RuntimeError(
            f"Error applying anyscale_v2_e2e_public gcp terraform: {stderr}"
        )
    print(f"Applied anyscale_v2_e2e_public gcp result: {stdout}")
    ## Register the cloud.
    cloud_name = (
        f"test_terraform_anyscale_v2_e2e_public_gcp_{datetime.now().isoformat()}"
    )
    stdout_dict = _parse_registration_command(stdout)
    print(f"Parsed stdout_dict: {stdout_dict}")
    print("Registering gcp cloud...")
    cloud_controller = CloudController()
    cloud_controller.register_gcp_cloud(
        region=stdout_dict.get("region"),
        name=cloud_name,
        project_id=stdout_dict.get("project-id"),
        vpc_name=stdout_dict.get("vpc-name"),
        subnet_names=stdout_dict.get("subnet-names").split(","),
        filestore_instance_id=stdout_dict.get("filestore-instance-id"),
        filestore_location=stdout_dict.get("filestore-location"),
        anyscale_service_account_email=stdout_dict.get(
            "anyscale-service-account-email"
        ),
        instance_service_account_email=stdout_dict.get(
            "instance-service-account-email"
        ),
        provider_id=stdout_dict.get("provider-name"),
        firewall_policy_names=stdout_dict.get("firewall-policy-names").split(","),
        cloud_storage_bucket_name=stdout_dict.get("cloud-storage-bucket-name"),
        # change to functional_verify="workspace,service" once service is ready.
        # For functional verify, the console will ask for your confirm to proceed.
        functional_verify="workspace",
        private_network=False,
        cluster_management_stack_version="v2",
        yes=True,
    )
    print("Cloud registered successfully")

    ## Delete the cloud.
    cloud_controller.delete_cloud(
        cloud_name=cloud_name,
        cloud_id="",
        skip_confirmation=True,
    )
    print("GCP Cloud deleted successfully")

    ## Destroy the terraform.
    print("Destroying anyscale_v2_e2e_public gcp terraform...")
    return_code, stdout, stderr = tf.destroy(force=IsNotFlagged, auto_approve=IsFlagged)
    if return_code != 0:
        raise RuntimeError(
            f"Error destroying anyscale_v2_e2e_public gcp terraform: {stderr}"
        )
    print(f"Destroyed anyscale_v2_e2e_public gcp terraform successfully {stdout}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--cloud-provider",
        "-c",
        required=True,
        type=str.lower,
        dest="cloudProvider",
        help="The cloud provider to use",
    )
    argGroup = parser.add_mutually_exclusive_group(required=True)
    argGroup.add_argument(
        "--branch-name",
        "-b",
        type=str,
        dest="branchName",
        help="The branch name to use",
    )
    argGroup.add_argument(
        "--local_path",
        "-l",
        type=str,
        dest="localPath",
        help="The local path to use",
    )
    # branch_name = input("What is your branch name? ")
    args, _ = parser.parse_known_args()
    cloud_provider = args.cloudProvider
    branch_name = args.branchName
    local_path = args.localPath

    if cloud_provider == "aws":
        start_aws_test(branch_name, local_path)
    elif cloud_provider == "gcp":
        start_gcp_test(branch_name, local_path)
    else:
        raise RuntimeError(f"Unsupported cloud provider: {cloud_provider}")
